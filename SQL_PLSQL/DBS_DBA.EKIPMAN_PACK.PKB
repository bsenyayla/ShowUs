CREATE OR REPLACE PACKAGE BODY DBS_DBA.ekipman_pack IS

   --- TEAM CODING
   FUNCTION eq_ekipman_hdd_var_mi (i_account_number IN NUMBER, i_outlet_location IN NUMBER)
      RETURN NUMBER IS
      v_count NUMBER;
   BEGIN   
      SELECT COUNT (*)
        INTO v_count
        FROM eq_ekipman
       WHERE account_number = i_account_number AND outlet_location = i_outlet_location AND ekipman_tipi = 302;

      IF v_count > 0 THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;

   -----------------------------------------------------------
   FUNCTION eq_hdd_zorunlu_ozellik_kutu (i_serial_number IN VARCHAR)
      RETURN NUMBER IS
      v_ekipman_tip_matrix_id NUMBER;
      v_ozellik_destekli      CHAR (1);
   BEGIN
      ekipman_pack.ekipman_ozellik (i_serial_number, NULL, NULL, 121, v_ekipman_tip_matrix_id, v_ozellik_destekli);

      IF v_ozellik_destekli = 'E' THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;

   PROCEDURE eq_ekipman_hdd_zorunlu_ozellik (i_account_number IN NUMBER, i_outlet_location IN CHAR, o_durum IN OUT VARCHAR) IS
      v_serial_number         VARCHAR2 (20);
      v_ekipman_tip_matrix_id NUMBER;
      v_ozellik_destekli      CHAR (1);
   BEGIN
      BEGIN
         SELECT serial_number
           INTO v_serial_number
           FROM wiz_equip
          WHERE account_number = i_account_number AND outlet_location = i_outlet_location AND converter_type = 'ST';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- Kutu yoksa harddisk eklenebilir
            -- kutu varsa kutunun HDD destekli olması kontrol edilmeli
            RETURN;
      END;

      ekipman_pack.ekipman_ozellik (v_serial_number, NULL, NULL, 121, v_ekipman_tip_matrix_id, v_ozellik_destekli);

      --özellik yoksa ekleme yapmaz
      IF v_ozellik_destekli = 'H' THEN
         o_durum := 'Üyenin üzerindeki Kutu tipi Harddisk Zorunlu özelliğine sahip degil. Üyeye HDD zorunlu özellikli kutu  eklemelisiniz!!';
         RETURN;
      END IF;
   END;

   -- Yurtiçi ise TRUE döner.
   PROCEDURE ekipman_yurtici_mi (in_serial_number IN VARCHAR2, out_yurtici OUT VARCHAR2, out_durum OUT VARCHAR2) IS
      vaccount_number      wiz_equip.account_number%TYPE;
      vequip_location_code wiz_equip.equip_location_code%TYPE;
      vfranchiscode        wiz_equip_location_codes.franchise_code%TYPE;
   BEGIN
      out_yurtici := 'H';
      out_durum   := '0';

      SELECT TRIM (account_number), equip_location_code
        INTO vaccount_number, vequip_location_code
        FROM wiz_equip
       WHERE serial_number = in_serial_number;

      -- ACCOUNT_NUMBER DOLU ISE onun franchise'ina göre karar verilir
      IF vaccount_number > 0 THEN
         SELECT franchise_code
           INTO vfranchiscode
           FROM wiz_customer_hp_life
          WHERE account_number = vaccount_number;
      ELSE
         SELECT franchise_code
           INTO vfranchiscode
           FROM wiz_equip_location_codes
          WHERE equip_location_code = vequip_location_code;
      END IF;

      IF vfranchiscode LIKE '%F01%' OR vfranchiscode LIKE '%F02%' THEN
         out_yurtici := 'E';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         out_durum := SUBSTR (SQLERRM, 1, 100);
   END;

   -----------------------------------------------------------------
   FUNCTION ekipman_riskli_mi (in_serial_number IN VARCHAR2)
      RETURN NUMBER IS
      /*
      1- evet ekipman riskli
      0- hayir ekipman risksiz.
      */
      v_ekipman_durum VARCHAR2 (8);
   BEGIN
      SELECT DECODE (p.versiyon_id,  184, 'RISK',  185, 'RISK',  186, 'RISK',  187, 'AZ_RISK',  188, 'AZ_RISK',  'RISKSIZ') durum
        INTO v_ekipman_durum
        FROM pr_kart_versiyon p
       WHERE in_serial_number BETWEEN p.ilk_aralik AND p.ikinci_aralik;

      IF v_ekipman_durum = 'RISKSIZ' THEN
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 1;
   END;

   PROCEDURE ekipman_transfer_edilebilir_mi (v_serial_sahiplik       IN     wiz_equip.serial_number%TYPE,
                                             v_ekipman_tip_matrix_id IN     NUMBER,
                                             v_cagrildigi_yer        IN     NUMBER,
                                             out_result                 OUT VARCHAR2,
                                             odurum                     OUT VARCHAR2,
                                             oproc_name              IN OUT VARCHAR2,
                                             oerror_type             IN OUT NUMBER,
                                             oerror_code             IN OUT VARCHAR2,
                                             oerror_text             IN OUT VARCHAR2
                                            ) IS
      vequiplocationcode         wiz_equip.equip_location_code%TYPE;
      v_count                    NUMBER (1);
      v_sahiplik_converter_type  eq_ekipman_tip_matrix.converter_type%TYPE;
      v_sahiplik_converter_model eq_ekipman_tip_matrix.converter_model%TYPE;
      v_sahiplik_manufacturer    eq_ekipman_tip_matrix.manufacturer%TYPE;
      v_sahiplik_transfer_et     BOOLEAN;
      v_sahiplik_ekipman_tip_id  NUMBER;
   --out_result = 1 => matrix tipleri aynidir transfer edilir
   --out_result = 2 => 52 ozelligi vardir, transfer edilmez ama isleme devam eder(else e girmez)
   --out_result = 3 => model ozellik kodu aynidir kutu degistirilebilir
   --out_result = 4 => transfer edilmez, islem devam etmez (else e girer)
   BEGIN
      odurum     := '0';
      out_result := NULL;

      BEGIN
         BEGIN
            SELECT equip_location_code, TRIM (converter_type), TRIM (converter_model), TRIM (manufacturer)
              INTO vequiplocationcode, v_sahiplik_converter_type, v_sahiplik_converter_model, v_sahiplik_manufacturer
              FROM wiz_equip
             WHERE serial_number = v_serial_sahiplik;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               SELECT equip_location_code, TRIM (ekipman_tipi), TRIM (ekipman_modul_tipi), NULL
                 INTO vequiplocationcode, v_sahiplik_converter_type, v_sahiplik_converter_model, v_sahiplik_manufacturer
                 --INTO vequiplocationcode, v_sahiplik_converter_type, v_sahiplik_converter_model, v_sahiplik_manufacturer
                 FROM eq_ekipman
                WHERE serial_number = v_serial_sahiplik;
         END;

         -- Sahipligi olan kutunun tip_id'si
         SELECT eq_ekipman_tip_matrix_id
           INTO v_sahiplik_ekipman_tip_id
           FROM eq_ekipman_tip_matrix
          WHERE     TRIM (converter_type) = TRIM (v_sahiplik_converter_type)
                AND NVL (TRIM (converter_model), '-1') = NVL (TRIM (v_sahiplik_converter_model), '-1')
                AND NVL (TRIM (manufacturer), '-1') = NVL (TRIM (v_sahiplik_manufacturer), '-1');

         IF v_cagrildigi_yer = 1 THEN
            SELECT COUNT (1)
              INTO v_count
              FROM wiz_equip_location_codes
             WHERE ust_depo_kod = 'KAYIP/CALINTI' AND equip_location_code = vequiplocationcode;

            IF v_count > 0 THEN
               odurum      := 'Üye bu outlet için ekipman satin almali. Öncelikle "Sahiplik" ekranindan satin alma islemi yapmalisiniz.';
               oproc_name  := 'EKIPMAN EKLE';
               oerror_type := 1;
               oerror_code := 'ERR362'; -- ??
               oerror_text := odurum;
               RETURN;
            END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            odurum      := 'HATA! Ekipman_transfer_edilebilir_mi: ' || SUBSTR (SQLERRM, 1, 100);
            oproc_name  := 'EKIPMAN EKLE';
            oerror_type := 1;
            oerror_code := 'ERR362'; -- ??
            oerror_text := odurum;
            RETURN;
      END;

      -- Model özellik kodu her ikisinde de(satin alinmis olan kutu ve eklenen kutu) ayni ise,
      -- sorun yok, islem kabul edilir, sahiplik transfer edilir
      -- modelleri farkli ise, hata verir.
      -- Sahipligi olan kutu için model tanimi yoksa onun yerine, sadece aynisi verilebilir

      -- Ancak bunu asan da bir özellik var : 52. Kutu modeli 52 özelligindeyse, onun yerine baska kutu da verilebilir,
      -- ancak sahiplik transfer olmaz
      --v_sahiplik_transfer_et := TRUE;
      IF v_sahiplik_ekipman_tip_id <> v_ekipman_tip_matrix_id THEN
         SELECT COUNT (1)
           INTO v_count
           FROM pr_genel_tip_detay
          WHERE     islem_kodu = 153
                AND tip_kodu IN (SELECT ozellik_kodu
                                   FROM pr_urun_ozellik_tanim
                                  WHERE urun_tipi = 6 AND ekipman_tip_matrix_id = v_ekipman_tip_matrix_id)
                AND tip_kodu IN (SELECT ozellik_kodu
                                   FROM pr_urun_ozellik_tanim
                                  WHERE urun_tipi = 6 AND ekipman_tip_matrix_id = v_sahiplik_ekipman_tip_id);

         IF v_count > 0 THEN
            SELECT COUNT (1)
              INTO v_count
              FROM eq_ekipman_tip_matrix e
             WHERE (eq_ekipman_tip_matrix_id = v_ekipman_tip_matrix_id OR eq_ekipman_tip_matrix_id = v_sahiplik_ekipman_tip_id) AND e.converter_type = '300';

            IF v_count = 2 THEN
               out_result := '5';
            ELSE
               out_result := '3';
            END IF;
         -- out_result := '3';
         ELSE
            SELECT COUNT (1)
              INTO v_count
              FROM pr_urun_ozellik_tanim
             WHERE urun_tipi = 6 AND ekipman_tip_matrix_id = v_sahiplik_ekipman_tip_id AND ozellik_kodu = 52;

            IF v_count > 0 THEN
               out_result := '2';
            ELSE
               out_result := '4';
            END IF;
         END IF;
      ELSE
         SELECT COUNT (1)
           INTO v_count
           FROM eq_ekipman_tip_matrix e
          WHERE (eq_ekipman_tip_matrix_id = v_ekipman_tip_matrix_id) AND e.converter_type = '300';

         IF v_count > 0 THEN
            out_result := '5';
         ELSE
            out_result := '1';
         END IF;
      --out_result := '1';
      END IF;
   END;

   -------------------------------------------------------------
   PROCEDURE ekipman_ozellik (in_serial_number            IN     VARCHAR2,
                              in_account_number           IN     NUMBER,
                              in_outlet_location          IN     VARCHAR2,
                              in_urun_ozellik_kodu        IN     NUMBER,
                              in_eq_ekipman_tip_matrix_id IN OUT NUMBER,
                              out_ozellik_destekli           OUT VARCHAR2
                             ) IS
      vmanufacturer           VARCHAR2 (2);
      vconvertermodel         VARCHAR2 (10);
      vconverter_type         VARCHAR2 (3);
      v_count                 NUMBER;
      v_ekipman_tip_matrix_id eq_ekipman_tip_matrix.eq_ekipman_tip_matrix_id%TYPE;
   BEGIN
      out_ozellik_destekli := 'H';

      IF NVL (in_eq_ekipman_tip_matrix_id, 0) = 0 THEN
         BEGIN
            IF in_serial_number IS NOT NULL THEN
               BEGIN
                  SELECT TRIM (manufacturer), TRIM (converter_model), TRIM (converter_type)
                    INTO vmanufacturer, vconvertermodel, vconverter_type
                    FROM wiz_equip e
                   WHERE e.serial_number = in_serial_number;
               --  AND e.converter_type = 'ST';
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT NULL AS manufacturer, TRIM (e.ekipman_modul_tipi), TRIM (ekipman_tipi)
                       INTO vmanufacturer, vconvertermodel, vconverter_type
                       FROM eq_ekipman e
                      WHERE e.serial_number = in_serial_number AND e.ekipman_tipi IN (248, 300, 301, 302);
               END;
            -- EKAYAN !!!! Dikkat DEV ve testte bir süre deneyelim. -- 23 Ekim 2009
            -- Seri no ile gelirse, kart kutu için çalışsın.
            -- Account ile gelirse, girişte ekipman tipi belirtmediği için kutu diye varsayalım.
            ELSIF in_account_number IS NOT NULL AND in_account_number <> 0 THEN
               BEGIN
                  SELECT NULL AS manufacturer, TRIM (e.ekipman_modul_tipi), TRIM (ekipman_tipi)
                    INTO vmanufacturer, vconvertermodel, vconverter_type
                    FROM eq_ekipman e
                   WHERE e.account_number = in_account_number AND e.outlet_location = in_outlet_location AND e.ekipman_tipi = 248;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT TRIM (manufacturer), TRIM (converter_model), TRIM (converter_type)
                       INTO vmanufacturer, vconvertermodel, vconverter_type
                       FROM wiz_equip e
                      WHERE e.account_number = in_account_number AND e.outlet_location = in_outlet_location AND e.converter_type = 'ST';
               END;
            ELSE
               RETURN;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN;
         END;

         BEGIN
            SELECT eq_ekipman_tip_matrix_id
              INTO v_ekipman_tip_matrix_id
              FROM eq_ekipman_tip_matrix e
             WHERE     NVL (TRIM (e.manufacturer), -1) = NVL (TRIM (vmanufacturer), -1)
                   AND NVL (TRIM (e.converter_model), -1) = NVL (TRIM (vconvertermodel), -1)
                   AND TRIM (e.converter_type) = vconverter_type;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN;
         END;

         in_eq_ekipman_tip_matrix_id := v_ekipman_tip_matrix_id;
      ELSE
         v_ekipman_tip_matrix_id := in_eq_ekipman_tip_matrix_id;
      END IF;

      SELECT COUNT (1)
        INTO v_count
        FROM pr_urun_ozellik_tanim
       WHERE urun_tipi = 6 AND ekipman_tip_matrix_id = v_ekipman_tip_matrix_id AND ozellik_kodu = in_urun_ozellik_kodu;

      IF v_count > 0 THEN
         out_ozellik_destekli := 'E';
      END IF;

      RETURN;
   END ekipman_ozellik;

   ----------------------------------------------------------
   -- satilik özelligi tanimlanmis olabilir ve
   -- ayrica detayda bu gruba dahil veya hariç ekipmanlar belirtilmis olabilir.
   -- Bknz : IBX0000950, DBS_PVR_Akis.doc
   -- Serino veya abone no ile sorgulama yapilabilir.
   FUNCTION ekipman_satilikmi (in_serial_number IN VARCHAR2, in_account_number IN NUMBER, in_outlet_location IN VARCHAR2, in_equip_location_code IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_satilik                  VARCHAR2 (1);
      v_eq_ekipman_tip_matrix_id NUMBER (10);
      v_serial_number            VARCHAR2 (20);

      CURSOR cekipmantip  IS
         SELECT   seri_no_baslangic, seri_no_bitis, equip_location_code, satilik
             FROM eq_ekipman_tip_satilik
            WHERE eq_ekipman_tip_matrix_id = v_eq_ekipman_tip_matrix_id AND listeden_gizle = 'H'
         ORDER BY equip_location_code NULLS LAST,
                  seri_no_baslangic NULLS LAST;
   /*
     eq_ekipman_tip_satilik tablosuna veri atilirken dikkat edilecek hususlar.
     1)Bu tablodaki verilerin geçerli olabilmesi için o ekipmana 31 öz. verilmis olmali.
     2)Sonra ya satilik olanlar bu tabloya dahil edilmeli veyahutta satilik olmayanlar bu tabloya dahil edilmeli
       Yani EK1-EK2 arasi satiliktir diye bir kayit atiliyorsa bu tip ekipmanin diger üyeleri satilik degildir manasi tasir.
     3)Ya seri_no_baslangic, seri_no_bitis, equip_location_code dolu olmali
       Ya sadece equip_location_code dolu olmali
       Ya Ya seri_no_baslangic, seri_no_bitis dolu olmali
     4)Verileri atarkende seri no vs alanlari çakismamali.
   */
   BEGIN
      v_eq_ekipman_tip_matrix_id := NULL; -- fonksiyondan matrix_id de döner.

      IF in_serial_number IS NULL THEN
         SELECT MIN (serial_number)
           INTO v_serial_number
           FROM eq_ekipman e
          WHERE e.account_number = in_account_number AND e.outlet_location = in_outlet_location AND e.ekipman_tipi = 248;

         IF v_serial_number IS NULL THEN
            SELECT MIN (serial_number)
              INTO v_serial_number
              FROM wiz_equip e
             WHERE e.account_number = in_account_number AND e.outlet_location = in_outlet_location AND e.converter_type = 'ST';
         END IF;
      ELSE
         v_serial_number := in_serial_number;
      END IF;

      ekipman_ozellik (v_serial_number, NULL, NULL, 31, v_eq_ekipman_tip_matrix_id, v_satilik);

      IF v_satilik = 'E' THEN
         FOR vekipmantip IN cekipmantip LOOP
            IF vekipmantip.satilik = 'E' THEN
               v_satilik := 'H';
            ELSE
               v_satilik := 'E';
            END IF;

            IF vekipmantip.equip_location_code = in_equip_location_code THEN
               IF vekipmantip.seri_no_baslangic <= v_serial_number AND v_serial_number <= vekipmantip.seri_no_bitis THEN
                  v_satilik := vekipmantip.satilik;
                  EXIT;
               ELSIF vekipmantip.seri_no_baslangic IS NULL AND vekipmantip.seri_no_bitis IS NULL THEN
                  v_satilik := vekipmantip.satilik;
                  EXIT;
               END IF;
            ELSIF vekipmantip.equip_location_code IS NULL THEN
               IF vekipmantip.seri_no_baslangic <= v_serial_number AND v_serial_number <= vekipmantip.seri_no_bitis THEN
                  v_satilik := vekipmantip.satilik;
                  EXIT;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN v_satilik;
   END ekipman_satilikmi;

   -------------------------------------------------------------
   -- IBX0000950 IRDETO
   -- Sinyal akisinda CAS veya IRDETO uygulamasinin seçiminde kullanilir
   PROCEDURE ekipman_irdeto_desteklimi (in_serial_number IN VARCHAR2, out_irdeto_destekli OUT VARCHAR2, out_durum OUT VARCHAR2) IS
      v_manufacturer    VARCHAR2 (10);
      v_converter_model VARCHAR2 (10);
      v_converter_type  VARCHAR2 (10);
   BEGIN
      out_irdeto_destekli := NULL;

      BEGIN
         SELECT TRIM (converter_type), TRIM (converter_model), TRIM (manufacturer)
           INTO v_converter_type, v_converter_model, v_manufacturer
           FROM wiz_equip e
          WHERE e.serial_number = in_serial_number;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT TRIM (ekipman_tipi), TRIM (e.ekipman_modul_tipi), NULL AS manufacturer
              INTO v_converter_type, v_converter_model, v_manufacturer
              FROM eq_ekipman e
             WHERE e.serial_number = in_serial_number;
         WHEN OTHERS THEN
            out_durum := 'Ekipman tanimli degil : ' || in_serial_number || SQLERRM;
            RETURN;
      END;

      SELECT irdeto_destekli
        INTO out_irdeto_destekli
        FROM eq_ekipman_tip_matrix e
       WHERE     NVL (TRIM (e.manufacturer), -1) = NVL (TRIM (v_manufacturer), -1)
             AND NVL (TRIM (e.converter_model), -1) = NVL (TRIM (v_converter_model), -1)
             AND TRIM (e.converter_type) = v_converter_type;
   EXCEPTION
      WHEN OTHERS THEN
         out_durum := 'Ekipman tipi bulunamadi';
   END;

   -------------------------------------------------------------
   FUNCTION ekipman_irdeto_desteklimi (in_serial_number IN VARCHAR2)
      RETURN VARCHAR2 IS
      out_irdeto_destelimi VARCHAR2 (1);
      out_durum            VARCHAR2 (1000);
   BEGIN
      ekipman_irdeto_desteklimi (in_serial_number, out_irdeto_destelimi, out_durum);
      RETURN out_irdeto_destelimi;
   END;

   -------------------------------------------------------------
   -- IBX0000950 IRDETO
   -- PVR kutu, PVR kart ile eslesebilir, digerleri de kendi arasinda.

   -- OUTPUT :
   -- SERIAL_NUMBERS : SC ve ST ekipmanin seri numaralari pair_chipset de kullanilmak üzere gönderiliri.
   -- Üyeye eklenmeye çalisilan ekipman (üye üzerindeki degil) PVOD destekli ise
   -- out_PVOD_destekli = "E" döner.
   -- Üyeye eklenmeye çalisilan ekipman birbiri ile uyumlu ise out_manufacturer_uyumlu = "E" döner
   -- Tek ekipman varsa uyumsuzdur hatasi verilmemelidir, E döner
   /* Eskisi kapatıldı yenisi yazıldı. 09.02.2011
      PROCEDURE ekipman_irdeto_desteklimi (
         in_account_number           IN       NUMBER,
         in_outlet_location          IN       VARCHAR2,
         in_serial_number            IN       VARCHAR2,
         in_manufacturer             IN       VARCHAR2,
         in_converter_type           IN       VARCHAR2,
         in_converter_model          IN       VARCHAR2,
         out_sc_serial_number        OUT      VARCHAR2,
         out_st_serial_number        OUT      VARCHAR2,
         out_manufacturer_uyumlu     OUT      VARCHAR2,
         -- E ise, uyumlu kart ve kutu
         out_irdetodestekliekipman   OUT      VARCHAR2,
         -- E ise, in_manufacturer PVOD desteklidir
         out_durum                   OUT      VARCHAR2
      )
      IS
         vconvertertype    wiz_equip.converter_type%TYPE;
         vmodul            NUMBER (1);

         TYPE t_record IS RECORD (
            serial_number           wiz_equip.serial_number%TYPE,
            manufacturer            eq_ekipman_tip_matrix.manufacturer%TYPE,
            converter_model         VARCHAR2 (10),
            irdetodestekliekipman   eq_ekipman_tip_matrix.irdeto_destekli%TYPE
         );

         TYPE t_ekipman_liste IS TABLE OF t_record
            INDEX BY VARCHAR2 (2);

         ekipman_tipleri   t_ekipman_liste;

         CURSOR cekipmantip
         IS
            SELECT converter_type, irdeto_destekli
              FROM eq_ekipman_tip_matrix e
             WHERE (    TRIM (e.manufacturer) = TRIM (in_manufacturer)
                    AND TRIM (e.converter_model) = TRIM (in_converter_model)
                    AND TRIM (e.converter_type) = in_converter_type
                   )
                OR (    TRIM (e.manufacturer) = ekipman_tipleri (vconvertertype).manufacturer
                    AND TRIM (e.converter_model) = ekipman_tipleri (vconvertertype).converter_model
                    AND TRIM (e.converter_type) = vconvertertype
                   );
      BEGIN
         out_durum := '0';
         out_manufacturer_uyumlu := 'H';
         out_irdetodestekliekipman := 'H';

         -- Abone üzerindeki kart veya kutunun modeli alinir ,
         -- Eklenmeye çalisilan ile uyumlu olmasi gerekir.
         IF in_converter_type = 'SC'
         THEN
            ekipman_tipleri ('SC').serial_number := in_serial_number;
            ekipman_tipleri ('ST').serial_number := '-1';
            vconvertertype := 'ST';
         ELSE
            ekipman_tipleri ('ST').serial_number := in_serial_number;
            ekipman_tipleri ('SC').serial_number := '-1';
            vconvertertype := 'SC';
         END IF;

         BEGIN
            SELECT TRIM (serial_number), TRIM (manufacturer),
                   TRIM (converter_model)
              INTO ekipman_tipleri (vconvertertype).serial_number, ekipman_tipleri (vconvertertype).manufacturer,
                   ekipman_tipleri (vconvertertype).converter_model
              FROM wiz_equip e
             WHERE e.account_number = in_account_number
               AND e.outlet_location = in_outlet_location
               AND e.converter_type = vconvertertype;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               -- Üzerinde henüz hiçbir ekipmani yoktur veya LG gibi kutusuz üyedir.

               -- Öyle olursa uyum aranamaz.
               out_manufacturer_uyumlu := 'E';
               out_irdetodestekliekipman := 'H';
               -- Üzerinde modül varsa uyumlu dönmez.
               vmodul := 0;

               SELECT COUNT (1)
                 INTO vmodul
                 FROM eq_ekipman
                WHERE account_number = in_account_number AND outlet_location = in_outlet_location;
   --            IF vmodul > 0
   --            THEN
   --               out_manufacturer_uyumlu := 'H';
   --               out_irdetodestekliekipman := 'H';
   --               vconvertertype := 'MD';
   --            END IF;
            WHEN OTHERS
            THEN
               -- ACCOUNT_NUMBER = 0 oldugunda abone olmuyor, bu da ekipmanin depodan depoya aktarimi demek.
               -- Öyle olursa uyum aranamaz.
               out_manufacturer_uyumlu := 'E';
               out_irdetodestekliekipman := 'H';
         END;

         FOR vekipmantip IN cekipmantip
         LOOP
            ekipman_tipleri (vekipmantip.converter_type).irdetodestekliekipman := vekipmantip.irdeto_destekli;
         END LOOP;

         out_sc_serial_number := ekipman_tipleri ('SC').serial_number;
         out_st_serial_number := ekipman_tipleri ('ST').serial_number;
         out_irdetodestekliekipman := ekipman_tipleri (in_converter_type).irdetodestekliekipman;

         IF out_irdetodestekliekipman = 'E'
         THEN
            IF vmodul > 0
            THEN
               out_manufacturer_uyumlu := 'H';
            ELSIF NVL (ekipman_tipleri (vconvertertype).irdetodestekliekipman, 'E') = 'E'
            THEN
               out_manufacturer_uyumlu := 'E';
            END IF;
         END IF;

         IF out_irdetodestekliekipman = 'H'
         THEN
            IF vmodul > 0
            THEN
               out_manufacturer_uyumlu := 'E';
            ELSIF NVL (ekipman_tipleri (vconvertertype).irdetodestekliekipman, 'H') = 'H'
            THEN
               out_manufacturer_uyumlu := 'E';
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            out_durum := 'Hata:' || SQLERRM;
      END ekipman_irdeto_desteklimi;
   */
   -------------------------------------------------------------
   -- IBX0000950 IRDETO
   -- PVR kutu, PVR kart ile eslesebilir, digerleri de kendi arasinda.

   -- OUTPUT :
   -- SERIAL_NUMBERS : SC ve ST ekipmanin seri numaralari pair_chipset de kullanilmak üzere gönderiliri.
   -- Üyeye eklenmeye çalisilan ekipman (üye üzerindeki degil) PVOD destekli ise
   -- out_PVOD_destekli = "E" döner.
   -- Üyeye eklenmeye çalisilan ekipman birbiri ile uyumlu ise out_manufacturer_uyumlu = "E" döner
   -- Tek ekipman varsa uyumsuzdur hatasi verilmemelidir, E döner
   PROCEDURE ekipman_irdeto_desteklimi (in_account_number         IN     NUMBER,
                                        in_outlet_location        IN     VARCHAR2,
                                        in_serial_number          IN     VARCHAR2,
                                        in_manufacturer           IN     VARCHAR2,
                                        in_converter_type         IN     VARCHAR2,
                                        in_converter_model        IN     VARCHAR2,
                                        in_islem                  IN     VARCHAR2,
                                        -- Ekleme için 'E' Çıkarma için 'C'
                                        out_sc_serial_number         OUT VARCHAR2,
                                        out_st_serial_number         OUT VARCHAR2,
                                        out_md_serial_number         OUT VARCHAR2,
                                        out_manufacturer_uyumlu      OUT VARCHAR2,
                                        -- E ise, uyumlu kart ve kutu
                                        out_irdetodestekliekipman    OUT VARCHAR2,
                                        -- E ise, in_manufacturer PVOD desteklidir
                                        out_durum                    OUT VARCHAR2
                                       ) IS
      TYPE t_record IS RECORD
      (
         serial_number         wiz_equip.serial_number%TYPE,
         manufacturer          eq_ekipman_tip_matrix.manufacturer%TYPE,
         converter_model       VARCHAR2 (10),
         irdetodestekliekipman eq_ekipman_tip_matrix.irdeto_destekli%TYPE
      );

      TYPE t_ekipman_liste IS TABLE OF t_record
         INDEX BY VARCHAR2 (3);

      ekipman_tipleri t_ekipman_liste;
   BEGIN
      out_durum                 := '0';
      out_manufacturer_uyumlu   := 'H';
      out_irdetodestekliekipman := 'H';

      -- Abone üzerindeki kart, kutu/Modül bilgileri alinir ,
      -- Eklenmeye çalisilan ile uyumlu olmasi gerekir.
      BEGIN
         SELECT TRIM (e.serial_number), TRIM (e.manufacturer), TRIM (e.converter_model), mtx.irdeto_destekli
           INTO ekipman_tipleri ('ST').serial_number,
                ekipman_tipleri ('ST').manufacturer,
                ekipman_tipleri ('ST').converter_model,
                ekipman_tipleri ('ST').irdetodestekliekipman
           FROM wiz_equip e,
                eq_ekipman_tip_matrix mtx
          WHERE     e.account_number = in_account_number
                AND in_account_number > 0
                AND e.outlet_location = in_outlet_location
                AND e.converter_type = 'ST'
                AND e.converter_type != in_converter_type
                AND TRIM (e.manufacturer) = TRIM (mtx.manufacturer)
                AND TRIM (e.converter_model) = TRIM (mtx.converter_model)
                AND TRIM (e.converter_type) = mtx.converter_type;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            ekipman_tipleri ('ST').serial_number := '-1';
         WHEN OTHERS THEN
            out_durum := 'Hata-ST: ' || SUBSTR (SQLERRM, 1, 255);
            RETURN;
      END;

      BEGIN
         SELECT TRIM (e.serial_number), TRIM (e.manufacturer), TRIM (e.converter_model), mtx.irdeto_destekli
           INTO ekipman_tipleri ('SC').serial_number,
                ekipman_tipleri ('SC').manufacturer,
                ekipman_tipleri ('SC').converter_model,
                ekipman_tipleri ('SC').irdetodestekliekipman
           FROM wiz_equip e,
                eq_ekipman_tip_matrix mtx
          WHERE     e.account_number = in_account_number
                AND in_account_number > 0
                AND e.outlet_location = in_outlet_location
                AND e.converter_type = 'SC'
                AND e.converter_type != in_converter_type
                AND TRIM (e.manufacturer) = TRIM (mtx.manufacturer)
                AND TRIM (e.converter_model) = TRIM (mtx.converter_model)
                AND TRIM (e.converter_type) = mtx.converter_type;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            ekipman_tipleri ('SC').serial_number := '-1';
         WHEN OTHERS THEN
            out_durum := 'Hata-SC: ' || SUBSTR (SQLERRM, 1, 255);
            RETURN;
      END;

      BEGIN
         SELECT TRIM (e.serial_number), NULL, e.ekipman_modul_tipi, mtx.irdeto_destekli
           INTO ekipman_tipleri ('248').serial_number,
                ekipman_tipleri ('248').manufacturer,
                ekipman_tipleri ('248').converter_model,
                ekipman_tipleri ('248').irdetodestekliekipman
           FROM eq_ekipman e,
                eq_ekipman_tip_matrix mtx
          WHERE     e.account_number = in_account_number
                AND in_account_number > 0
                AND e.outlet_location = in_outlet_location
                AND e.ekipman_tipi = '248'
                AND '248' != in_converter_type
                AND '248' = mtx.converter_type
                AND TRIM (mtx.manufacturer) IS NULL
                AND NVL (TRIM (mtx.converter_model), -1) = NVL (TRIM (e.ekipman_modul_tipi), -1);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF in_converter_type <> '302' THEN
               ekipman_tipleri ('248').serial_number := '-1';
            ELSE
               ekipman_tipleri ('302').serial_number := '-1';
            END IF;
         WHEN OTHERS THEN
            out_durum := 'Hata-MD: ' || SUBSTR (SQLERRM, 1, 255);
            RETURN;
      END;

      -- Eklenmek ve çıkarılmak için gönderilen ekipman bilgilerini de ekliyor.
      IF in_islem = 'E' THEN
         ekipman_tipleri (in_converter_type).serial_number   := in_serial_number;
         ekipman_tipleri (in_converter_type).converter_model := in_converter_model;
         ekipman_tipleri (in_converter_type).manufacturer    := in_manufacturer;
      END IF;

      BEGIN
         -- kutu kart harici irdetoya girme
         -- ozgur arslan
         --   if in_converter_type in ('247','246') then
         SELECT irdeto_destekli
           INTO ekipman_tipleri (in_converter_type).irdetodestekliekipman
           FROM eq_ekipman_tip_matrix e
          WHERE     NVL (TRIM (e.manufacturer), -1) = NVL (TRIM (in_manufacturer), -1)
                AND NVL (TRIM (e.converter_model), -1) = NVL (TRIM (in_converter_model), -1)
                AND TRIM (e.converter_type) = in_converter_type;
      -- and  in_converter_type not in('302');
      -- end if;
      EXCEPTION
         WHEN OTHERS THEN
            out_durum := 'Gonderilen Ekipman için Matrix Bilgisi Hatası: ' || SUBSTR (SQLERRM, 1, 255) || '  converter_type:' || in_converter_type;
            RETURN;
      END;

      out_sc_serial_number      := ekipman_tipleri ('SC').serial_number;
      out_st_serial_number      := ekipman_tipleri ('ST').serial_number;
      out_md_serial_number      := ekipman_tipleri ('248').serial_number;
      out_irdetodestekliekipman := ekipman_tipleri (in_converter_type).irdetodestekliekipman;
      out_manufacturer_uyumlu   := 'E';

      /* Kart-kutu-modül Eklenebilme kuralları */
      -- 1 Kart dikkate alınmaksızın irdeto kutu ve irdeto modül aynı anda eklenemez.
      -- 2 Kart dikkate alınmaksızın irdeto kutu ve cyrpto modül aynı anda eklenemez.
      -- yukardaki 2 özellik tek kontrolde sağlandı(irdeto kutu ile herhangi bir modül birlikte eklenemez.).
      IF ekipman_tipleri ('ST').serial_number != '-1' AND ekipman_tipleri ('ST').irdetodestekliekipman = 'E' AND ekipman_tipleri ('248').serial_number != '-1' THEN
         out_manufacturer_uyumlu := 'H';
      END IF;

      -- 3 Kutu dikkate alınmaksızın irdeto kart ve cyrpto modül aynı anda eklenemez.
      IF     ekipman_tipleri ('SC').serial_number != '-1'
         AND ekipman_tipleri ('SC').irdetodestekliekipman = 'E'
         AND ekipman_tipleri ('248').serial_number != '-1'
         AND ekipman_tipleri ('248').irdetodestekliekipman = 'H' THEN
         out_manufacturer_uyumlu := 'H';
      END IF;

      -- 4 Kart irdeto, kutu cyrpto ve modülde bulunmuyorsa eklemeye izin verme
      IF     ekipman_tipleri ('SC').serial_number != '-1'
         AND ekipman_tipleri ('SC').irdetodestekliekipman = 'E'
         AND ekipman_tipleri ('ST').serial_number != '-1'
         AND ekipman_tipleri ('ST').irdetodestekliekipman = 'H'
         AND ekipman_tipleri ('248').serial_number = '-1' THEN
         out_manufacturer_uyumlu := 'H';
      END IF;

      -- 5 Kart cyrpto iken modül irdeto olamaz
      IF     ekipman_tipleri ('SC').serial_number != '-1'
         AND ekipman_tipleri ('SC').irdetodestekliekipman = 'H'
         AND ekipman_tipleri ('248').serial_number != '-1'
         AND ekipman_tipleri ('248').irdetodestekliekipman = 'E' THEN
         out_manufacturer_uyumlu := 'H';
      END IF;

      -- 6 Kart cyrpto iken kutu irdeto olamaz
      IF     ekipman_tipleri ('SC').serial_number != '-1'
         AND ekipman_tipleri ('SC').irdetodestekliekipman = 'H'
         AND ekipman_tipleri ('ST').serial_number != '-1'
         AND ekipman_tipleri ('ST').irdetodestekliekipman = 'E' THEN
         out_manufacturer_uyumlu := 'H';
      END IF;

      /* Eklenebilme kuralları bitiş*/
      -- İrdeto destekli mi kontrolü için kart irdeto kutu cyrpto ve modül irdeto ise irdeto desteklisi evet dönsün Yoksa en son kutu eklenilince yanlış sinyaller çıkıyor.
      IF     ekipman_tipleri ('ST').serial_number != '-1'
         AND ekipman_tipleri ('ST').irdetodestekliekipman = 'H'
         AND ekipman_tipleri ('SC').serial_number != '-1'
         AND ekipman_tipleri ('SC').irdetodestekliekipman = 'E'
         AND ekipman_tipleri ('248').serial_number != '-1'
         AND ekipman_tipleri ('248').irdetodestekliekipman = 'E' THEN
         out_irdetodestekliekipman := 'E';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         out_durum := 'Hata:' || SQLERRM;
   END ekipman_irdeto_desteklimi;

   PROCEDURE tlf_ekipman_islemi_yapilabilir (iislem_tipi                IN     VARCHAR2,
                                             ialt_islem_tipi            IN     VARCHAR2,
                                             iotorizasyon_no            IN     its_servis.kayit_no%TYPE,
                                             ilg_teknik_servis_sifre_id IN     lg_teknik_servis_sifre.id%TYPE,
                                             its_no                     IN     lg_ekipman.sales_agent_code%TYPE,
                                             istb_depo_kodu             IN     lg_ekipman.depoya%TYPE,
                                             imd_depo_kodu              IN     lg_ekipman.depoya%TYPE,
                                             isc_depo_kodu              IN     lg_ekipman.depoya%TYPE,
                                             iuye_no                    IN     wiz_equip.account_number%TYPE,
                                             ioutlet_location           IN     wiz_equip.outlet_location%TYPE,
                                             istb_serial_number         IN     wiz_equip.serial_number%TYPE,
                                             imd_serial_number          IN     eq_ekipman.serial_number%TYPE,
                                             isc_serial_number          IN     wiz_equip.serial_number%TYPE,
                                             inew_stb_serial_number     IN     wiz_equip.serial_number%TYPE,
                                             inew_md_serial_number      IN     eq_ekipman.serial_number%TYPE,
                                             inew_sc_serial_number      IN     wiz_equip.serial_number%TYPE,
                                             istb_kayip                 IN     CHAR,
                                             imd_kayip                  IN     CHAR,
                                             isc_kayip                  IN     CHAR,
                                             its_form_no                IN     lg_ekipman.ts_form_no%TYPE,
                                             igiren_kullanici           IN     co_kullanici.kod%TYPE,
                                             odurum                        OUT VARCHAR2
                                            ) IS
      v_sales_agent_code            bt_uye_ts.sales_agent_code%TYPE; -- bahadır Şenyayla                                            
      v_sc_outlet_location          wiz_equip.outlet_location%TYPE;
      v_stb_outlet_location         wiz_equip.outlet_location%TYPE;
      v_md_outlet_location          eq_ekipman.outlet_location%TYPE;
      v_sc_converter_type           wiz_equip.converter_type%TYPE;
      v_stb_converter_type          wiz_equip.converter_type%TYPE;
      --  v_md_converter_type             eq_ekipman.ekipman_tipi%TYPE;
      v_md_converter_type           VARCHAR2 (3);
      v_sc_equip_location_code      wiz_equip.equip_location_code%TYPE;
      v_stb_equip_location_code     wiz_equip.equip_location_code%TYPE;
      v_md_equip_location_code      eq_ekipman.equip_location_code%TYPE;
      v_sc_account_number           wiz_equip.account_number%TYPE;
      v_stb_account_number          wiz_equip.account_number%TYPE;
      v_md_account_number           eq_ekipman.account_number%TYPE;
      x_eski_stb_seri_no            its_servis.eski_stb_seri_no%TYPE;
      x_uye_eski_sc_seri_no         its_servis.uye_eski_sc_seri_no%TYPE;
      x_stb_seri_no                 its_servis.eski_stb_seri_no%TYPE;
      x_ts_no                       its_servis.ts_no%TYPE;
      x_uye_no                      its_servis.uye_no%TYPE;
      x_uye_sc_seri_no              its_servis.uye_sc_seri_no%TYPE;
      v_count                       NUMBER := 0;
      v_new_sc_outlet_location      wiz_equip.outlet_location%TYPE;
      v_new_stb_outlet_location     wiz_equip.outlet_location%TYPE;
      v_new_md_outlet_location      eq_ekipman.outlet_location%TYPE;
      v_new_sc_converter_type       wiz_equip.converter_type%TYPE;
      v_new_stb_converter_type      wiz_equip.converter_type%TYPE;
      v_new_md_converter_type       eq_ekipman.ekipman_tipi%TYPE;
      v_new_sc_equip_location_code  wiz_equip.equip_location_code%TYPE;
      v_new_stb_equip_location_code wiz_equip.equip_location_code%TYPE;
      v_new_md_equip_location_code  eq_ekipman.equip_location_code%TYPE;
      v_new_sc_account_number       wiz_equip.account_number%TYPE;
      v_new_stb_account_number      wiz_equip.account_number%TYPE;
      v_new_md_account_number       eq_ekipman.account_number%TYPE;
      v_iris_kullanici              NUMBER := 0;
   BEGIN
      odurum := '0';

      IF igiren_kullanici IN ('SYSIRIS', 'SYSIVR') THEN
         v_iris_kullanici := 1;
      END IF;

      IF TRIM (iuye_no) IS NULL THEN
         odurum := 'ÜYE NO BOS.';
         RETURN;
      ELSIF TRIM (its_no) IS NULL AND v_iris_kullanici = 0 THEN
         odurum := 'TS NUMARASI BOS.';
         RETURN;
      ELSIF TRIM (ilg_teknik_servis_sifre_id) IS NULL AND v_iris_kullanici = 0 THEN
         odurum := 'VALIDASYON GEÇIS ID ELDE EDILEMEDI.';
         RETURN;
      END IF;

      IF iislem_tipi = 'EKIPMAN_DEGISIM' THEN
         IF ialt_islem_tipi NOT IN ('SC_DEGISIM', 'STB_DEGISIM', 'MD_DEGISIM', 'STB_MD_DEGISIM', 'KEN_DEGISIM') THEN
            odurum := 'ALT ISLEM TIPI HATALI.' || ialt_islem_tipi;
            RETURN;
         END IF;

         IF ialt_islem_tipi = 'SC_DEGISIM' OR ialt_islem_tipi = 'STB_MD_DEGISIM' --OR ialt_islem_tipi = 'SC_STB_DEGISIM'
                                                                                THEN
            IF TRIM (isc_depo_kodu) IS NULL THEN
               odurum := 'SC DEPO KODU BOS.';
               RETURN;
            END IF;

            IF TRIM (isc_serial_number) IS NULL THEN
               odurum := 'MEVCUT SC EKIPMAN NUMARASI BOS.';
               RETURN;
            END IF;

            IF TRIM (inew_sc_serial_number) IS NULL THEN
               odurum := 'YENI SC EKIPMAN NUMARASI BOS.';
               RETURN;
            END IF;

            IF TRIM (isc_serial_number) = TRIM (inew_sc_serial_number) THEN
               odurum := 'ESKI ve YENI SC EKIPMAN NUMARALARI AYNI OLAMAZ.';
               RETURN;
            END IF;

            IF TRIM (isc_serial_number) IS NOT NULL THEN
               BEGIN
                  SELECT outlet_location, converter_type, equip_location_code, account_number
                    INTO v_sc_outlet_location, v_sc_converter_type, v_sc_equip_location_code, v_sc_account_number
                    FROM wiz_equip
                   WHERE serial_number = isc_serial_number;
               EXCEPTION
                  WHEN OTHERS THEN
                     odurum := 'EKIPMAN SISTEMDE KAYITLI DEGIL.EKIPMAN NO:' || isc_serial_number;
                     RETURN;
               END;
            END IF;

            IF TRIM (inew_sc_serial_number) IS NOT NULL THEN
               BEGIN
                  SELECT outlet_location, converter_type, equip_location_code, account_number
                    INTO v_new_sc_outlet_location, v_new_sc_converter_type, v_new_sc_equip_location_code, v_new_sc_account_number
                    FROM wiz_equip
                   WHERE serial_number = inew_sc_serial_number;
               EXCEPTION
                  WHEN OTHERS THEN
                     odurum := 'EKIPMAN SISTEMDE KAYITLI DEGIL.EKIPMAN NO:' || inew_sc_serial_number;
                     RETURN;
               END;
            END IF;

            IF TRIM (v_new_sc_equip_location_code) IS NULL THEN
               odurum := 'YENI EKIPMAN ZATEN BIR ÜYEDE.';
               RETURN;
            END IF;

            IF TRIM (v_sc_converter_type) <> TRIM (v_new_sc_converter_type) THEN
               odurum := 'DEGISIMDE KULLANILAN EKIPMAN TIPLERI BIRBIRINDEN FARKLI.';
               RETURN;
            END IF;

            IF TRIM (v_sc_converter_type) <> 'SC' OR TRIM (v_new_sc_converter_type) <> 'SC' THEN
               odurum := 'DEGISIMDE KULLANILAN EKIPMAN TIPLERI SC DEGIL.';
               RETURN;
            END IF;
         END IF;

         IF ialt_islem_tipi = 'STB_DEGISIM' --OR ialt_islem_tipi = 'SC_STB_DEGISIM'
                                           THEN
            IF TRIM (istb_depo_kodu) IS NULL THEN
               odurum := 'STB DEPO KODU BOS.';
               RETURN;
            END IF;

            IF TRIM (istb_serial_number) IS NULL THEN
               odurum := 'MEVCUT STB EKIPMAN NUMARASI BOS.';
               RETURN;
            END IF;

            IF TRIM (inew_stb_serial_number) IS NULL THEN
               odurum := 'YENI STB EKIPMAN NUMARASI BOS.';
               RETURN;
            END IF;

            IF TRIM (istb_serial_number) = TRIM (inew_stb_serial_number) THEN
               odurum := 'ESKI ve YENI STB EKIPMAN NUMARALARI AYNI OLAMAZ.';
               RETURN;
            END IF;

            IF TRIM (istb_serial_number) IS NOT NULL THEN
               BEGIN
                  SELECT outlet_location, converter_type, equip_location_code, account_number
                    INTO v_stb_outlet_location, v_stb_converter_type, v_stb_equip_location_code, v_stb_account_number
                    FROM wiz_equip
                   WHERE serial_number = istb_serial_number;
               EXCEPTION
                  WHEN OTHERS THEN
                     odurum := 'EKIPMAN SISTEMDE KAYITLI DEGIL.EKIPMAN NO:' || istb_serial_number;
                     RETURN;
               END;
            END IF;

            IF TRIM (inew_stb_serial_number) IS NOT NULL THEN
               BEGIN
                  SELECT outlet_location, converter_type, equip_location_code, account_number
                    INTO v_new_stb_outlet_location, v_new_stb_converter_type, v_new_stb_equip_location_code, v_new_stb_account_number
                    FROM wiz_equip
                   WHERE serial_number = inew_stb_serial_number;
               EXCEPTION
                  WHEN OTHERS THEN
                     odurum := 'EKIPMAN SISTEMDE KAYITLI DEGIL.EKIPMAN NO:' || inew_stb_serial_number;
                     RETURN;
               END;
            END IF;

            IF TRIM (v_new_stb_equip_location_code) IS NULL THEN
               odurum := 'YENI EKIPMAN ZATEN BIR ÜYEDE.';
               RETURN;
            END IF;

            IF TRIM (v_stb_converter_type) <> TRIM (v_new_stb_converter_type) THEN
               odurum := 'DEGISIMDE KULLANILAN EKIPMAN TIPLERI BIRBIRINDEN FARKLI.';
               RETURN;
            END IF;

            IF TRIM (v_stb_converter_type) <> 'ST' OR TRIM (v_new_stb_converter_type) <> 'ST' THEN
               odurum := 'DEGISIMDE KULLANILAN EKIPMAN TIPLERI STB DEGIL.';
               RETURN;
            END IF;
         END IF; -- falamur

         IF ialt_islem_tipi = 'MD_DEGISIM' THEN
            IF TRIM (imd_depo_kodu) IS NULL THEN
               odurum := 'MODÜL DEPO KODU BOS.';
               RETURN;
            END IF;

            IF TRIM (imd_serial_number) IS NULL THEN
               odurum := 'MEVCUT MODUL EKIPMAN NUMARASI BOS.';
               RETURN;
            END IF;

            IF TRIM (inew_md_serial_number) IS NULL THEN
               odurum := 'YENI MODUL EKIPMAN NUMARASI BOS.';
               RETURN;
            END IF;

            IF TRIM (imd_serial_number) = TRIM (inew_md_serial_number) THEN
               odurum := 'ESKI ve YENI MODÜL EKIPMAN NUMARALARI AYNI OLAMAZ.';
               RETURN;
            END IF;

            IF TRIM (imd_serial_number) IS NOT NULL THEN
               BEGIN
                  SELECT outlet_location, TRIM (ekipman_tipi), equip_location_code, account_number
                    INTO v_md_outlet_location, v_md_converter_type, v_md_equip_location_code, v_md_account_number
                    FROM eq_ekipman
                   WHERE serial_number = imd_serial_number;
               EXCEPTION
                  WHEN OTHERS THEN
                     odurum := 'MODÜL SISTEMDE KAYITLI DEGIL.EKIPMAN NO:' || imd_serial_number;
                     RETURN;
               END;
            END IF;

            IF TRIM (inew_md_serial_number) IS NOT NULL THEN
               BEGIN
                  SELECT outlet_location, TRIM (ekipman_tipi), equip_location_code, account_number
                    INTO v_new_md_outlet_location, v_new_md_converter_type, v_new_md_equip_location_code, v_new_md_account_number
                    FROM eq_ekipman
                   WHERE serial_number = inew_md_serial_number;
               EXCEPTION
                  WHEN OTHERS THEN
                     odurum := 'YENI MODÜL SISTEMDE KAYITLI DEGIL.EKIPMAN NO:' || inew_md_serial_number;
                     RETURN;
               END;
            END IF;

            IF TRIM (v_new_md_equip_location_code) IS NULL THEN
               odurum := 'YENI EKIPMAN ZATEN BIR ÜYEDE.';
               RETURN;
            END IF;

            IF TRIM (v_md_converter_type) <> TRIM (v_new_md_converter_type) THEN
               odurum := 'DEGISIMDE KULLANILAN EKIPMAN TIPLERI BIRBIRINDEN FARKLI.';
               RETURN;
            END IF;

            IF TRIM (v_md_converter_type) <> '248' OR TRIM (v_new_md_converter_type) <> '248' THEN
               odurum := 'DEGISIMDE KULLANILAN EKIPMAN TIPLERI MODÜL DEGIL.';
               RETURN;
            END IF;
         END IF;

         -- 22022011 Ken Degisimi eklendi.
         IF ialt_islem_tipi = 'KEN_DEGISIM' THEN
            IF TRIM (imd_depo_kodu) IS NULL THEN
               odurum := 'KEN / MODEM DEPO KODU BOS.';
               RETURN;
            END IF;

            IF TRIM (imd_serial_number) IS NULL THEN
               odurum := 'MEVCUT KEN / MODEM EKIPMAN NUMARASI BOS.';
               RETURN;
            END IF;

            IF TRIM (inew_md_serial_number) IS NULL THEN
               odurum := 'YENI KEN / MODEM EKIPMAN NUMARASI BOS.';
               RETURN;
            END IF;

            IF TRIM (imd_serial_number) = TRIM (inew_md_serial_number) THEN
               odurum := 'ESKI ve YENI  KEN / MODEM NUMARALARI AYNI OLAMAZ.';
               RETURN;
            END IF;

            IF TRIM (imd_serial_number) IS NOT NULL THEN
               BEGIN
                  SELECT outlet_location, TRIM (ekipman_tipi), equip_location_code, account_number
                    INTO v_md_outlet_location, v_md_converter_type, v_md_equip_location_code, v_md_account_number
                    FROM eq_ekipman
                   WHERE serial_number = imd_serial_number;
               EXCEPTION
                  WHEN OTHERS THEN
                     odurum := 'KEN / MODEM SISTEMDE KAYITLI DEGIL.EKIPMAN NO:' || imd_serial_number;
                     RETURN;
               END;
            END IF;

            IF TRIM (inew_md_serial_number) IS NOT NULL THEN
               BEGIN
                  SELECT outlet_location, TRIM (ekipman_tipi), equip_location_code, account_number
                    INTO v_new_md_outlet_location, v_new_md_converter_type, v_new_md_equip_location_code, v_new_md_account_number
                    FROM eq_ekipman
                   WHERE serial_number = inew_md_serial_number;
               EXCEPTION
                  WHEN OTHERS THEN
                     odurum := 'YENI KEN / MODEM SISTEMDE KAYITLI DEGIL.EKIPMAN NO:' || inew_md_serial_number;
                     RETURN;
               END;
            END IF;

            IF TRIM (v_new_md_equip_location_code) IS NULL THEN
               odurum := 'YENI EKIPMAN ZATEN BIR ÜYEDE.';
               RETURN;
            END IF;

            IF TRIM (v_md_converter_type) <> TRIM (v_new_md_converter_type) THEN
               odurum := 'DEGISIMDE KULLANILAN EKIPMAN TIPLERI BIRBIRINDEN FARKLI.';
               RETURN;
            END IF;

            -- ozgur arslan
            IF NOT (TRIM (v_md_converter_type) <> '300' OR TRIM (v_md_converter_type) <> '301' OR TRIM (v_md_converter_type) <> '302') THEN
               odurum := 'DEGISIMDE KULLANILAN EKIPMAN TIPLERI KEN / MODEM / HDD DEGIL.';
               RETURN;
            END IF;
         END IF;

         -- 06052011 falamur Yeni eklendi
         IF ialt_islem_tipi = 'STB_MD_DEGISIM' THEN
            IF TRIM (inew_stb_serial_number) IS NULL AND TRIM (inew_md_serial_number) IS NULL THEN
               odurum := 'YENİ STB veya YENİ MODÜL BİLGİSİNDEN EN AZ BİRİ BULUNMALIDIR.';
               RETURN;
            END IF;

            IF TRIM (istb_serial_number) IS NOT NULL AND TRIM (istb_depo_kodu) IS NULL THEN
               odurum := 'STB DEPO KODU BOŞ...';
               RETURN;
            END IF;

            IF TRIM (imd_serial_number) IS NOT NULL AND TRIM (imd_depo_kodu) IS NULL THEN
               odurum := 'MODÜL DEPO KODU BOŞ...';
               RETURN;
            END IF;

            IF     TRIM (inew_stb_serial_number) IS NOT NULL
               AND TRIM (istb_serial_number) IS NOT NULL
               AND TRIM (inew_stb_serial_number) = TRIM (istb_serial_number) THEN
               odurum := 'ESKI ve YENI STB EKIPMAN NUMARALARI AYNI OLAMAZ.';
               RETURN;
            END IF;

            IF TRIM (inew_md_serial_number) IS NOT NULL AND TRIM (imd_serial_number) IS NOT NULL AND TRIM (inew_md_serial_number) = TRIM (imd_serial_number) THEN
               odurum := 'ESKI ve YENI MODÜL EKIPMAN NUMARALARI AYNI OLAMAZ.';
               RETURN;
            END IF;

            IF TRIM (imd_serial_number) IS NOT NULL THEN
               BEGIN
                  SELECT outlet_location, TRIM (ekipman_tipi), equip_location_code, account_number
                    INTO v_md_outlet_location, v_md_converter_type, v_md_equip_location_code, v_md_account_number
                    FROM eq_ekipman
                   WHERE serial_number = imd_serial_number;
               EXCEPTION
                  WHEN OTHERS THEN
                     odurum := 'MODÜL SISTEMDE KAYITLI DEGIL.EKIPMAN NO:' || imd_serial_number;
                     RETURN;
               END;
            END IF;

            IF TRIM (inew_md_serial_number) IS NOT NULL THEN
               BEGIN
                  SELECT outlet_location, TRIM (ekipman_tipi), equip_location_code, account_number
                    INTO v_new_md_outlet_location, v_new_md_converter_type, v_new_md_equip_location_code, v_new_md_account_number
                    FROM eq_ekipman
                   WHERE serial_number = inew_md_serial_number;

                  IF TRIM (v_new_md_equip_location_code) IS NULL THEN
                     odurum := 'YENI MODÜL ZATEN BIR ÜYEDE.';
                     RETURN;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     odurum := 'MODÜL SISTEMDE KAYITLI DEGIL.EKIPMAN NO:' || inew_md_serial_number;
                     RETURN;
               END;
            END IF;

            IF     TRIM (v_md_converter_type) IS NOT NULL
               AND TRIM (v_new_md_converter_type) IS NOT NULL
               AND TRIM (v_md_converter_type) <> TRIM (v_new_md_converter_type) THEN
               odurum := 'DEGISIMDE KULLANILAN MODUL ICIN EKIPMAN TIPLERI BIRBIRINDEN FARKLI.';
               RETURN;
            END IF;

            IF    TRIM (v_md_converter_type) IS NOT NULL AND TRIM (v_new_md_converter_type) IS NOT NULL AND TRIM (v_md_converter_type) <> '248'
               OR TRIM (v_new_md_converter_type) <> '248' THEN
               odurum := 'DEGISIMDE KULLANILAN EKIPMAN TIPLERI MODÜL DEGIL.';
               RETURN;
            END IF;

            IF TRIM (istb_serial_number) IS NOT NULL THEN
               BEGIN
                  SELECT outlet_location, converter_type, equip_location_code, account_number
                    INTO v_stb_outlet_location, v_stb_converter_type, v_stb_equip_location_code, v_stb_account_number
                    FROM wiz_equip
                   WHERE serial_number = istb_serial_number;
               EXCEPTION
                  WHEN OTHERS THEN
                     odurum := 'EKIPMAN SISTEMDE KAYITLI DEGIL.EKIPMAN NO:' || istb_serial_number;
                     RETURN;
               END;
            END IF;

            IF TRIM (inew_stb_serial_number) IS NOT NULL THEN
               BEGIN
                  SELECT outlet_location, converter_type, equip_location_code, account_number
                    INTO v_new_stb_outlet_location, v_new_stb_converter_type, v_new_stb_equip_location_code, v_new_stb_account_number
                    FROM wiz_equip
                   WHERE serial_number = inew_stb_serial_number;

                  IF TRIM (v_new_stb_equip_location_code) IS NULL THEN
                     odurum := 'YENI STB ZATEN BIR ÜYEDE.';
                     RETURN;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     odurum := 'EKIPMAN SISTEMDE KAYITLI DEGIL.EKIPMAN NO:' || inew_stb_serial_number;
                     RETURN;
               END;
            END IF;

            IF     TRIM (v_stb_converter_type) IS NOT NULL
               AND TRIM (v_new_stb_converter_type) IS NOT NULL
               AND TRIM (v_stb_converter_type) <> TRIM (v_new_stb_converter_type) THEN
               odurum := 'DEGISIMDE KULLANILAN STB ICIN EKIPMAN TIPLERI BIRBIRINDEN FARKLI.';
               RETURN;
            END IF;

            IF    TRIM (v_stb_converter_type) IS NOT NULL AND TRIM (v_new_stb_converter_type) IS NOT NULL AND TRIM (v_stb_converter_type) <> 'ST'
               OR TRIM (v_new_stb_converter_type) <> 'ST' THEN
               odurum := 'DEGISIMDE KULLANILAN EKIPMAN TIPLERI STB DEGIL.';
               RETURN;
            END IF;
         END IF;
      ELSIF iislem_tipi = 'EKIPMAN_IADE' THEN
         IF TRIM (isc_serial_number) IS NULL AND TRIM (istb_serial_number) IS NULL AND TRIM (imd_serial_number) IS NULL THEN
            odurum := 'EKIPMAN NUMARALARI BOS.';
            RETURN;
         END IF;

         IF TRIM (istb_serial_number) IS NOT NULL THEN
            IF TRIM (istb_depo_kodu) IS NULL THEN
               odurum := 'STB DEPO KODU BOS.';
               RETURN;
            END IF;
         END IF;

         IF TRIM (imd_serial_number) IS NOT NULL THEN
            IF TRIM (imd_depo_kodu) IS NULL THEN
               odurum := 'MODUL DEPO KODU BOS.';
               RETURN;
            END IF;
         END IF;

         IF TRIM (isc_serial_number) IS NOT NULL THEN
            IF TRIM (isc_depo_kodu) IS NULL THEN
               odurum := 'SC DEPO KODU BOS.';
               RETURN;
            END IF;
         END IF;

         IF TRIM (istb_serial_number) IS NOT NULL THEN
            BEGIN
               SELECT outlet_location, converter_type, equip_location_code, account_number
                 INTO v_stb_outlet_location, v_stb_converter_type, v_stb_equip_location_code, v_stb_account_number
                 FROM wiz_equip
                WHERE serial_number = istb_serial_number;
            EXCEPTION
               WHEN OTHERS THEN
                  odurum := 'EKIPMAN SISTEMDE KAYITLI DEGIL.EKIPMAN NO:' || istb_serial_number;
                  RETURN;
            END;
         END IF;

         IF TRIM (imd_serial_number) IS NOT NULL THEN
            BEGIN
               SELECT outlet_location, TRIM (ekipman_tipi), equip_location_code, account_number
                 INTO v_md_outlet_location, v_md_converter_type, v_md_equip_location_code, v_md_account_number
                 FROM eq_ekipman
                WHERE serial_number = imd_serial_number;
            EXCEPTION
               WHEN OTHERS THEN
                  odurum := 'MODÜL SISTEMDE KAYITLI DEGIL.EKIPMAN NO:' || imd_serial_number;
                  RETURN;
            END;
         END IF;

         IF TRIM (isc_serial_number) IS NOT NULL THEN
            BEGIN
               SELECT outlet_location, converter_type, equip_location_code, account_number
                 INTO v_sc_outlet_location, v_sc_converter_type, v_sc_equip_location_code, v_sc_account_number
                 FROM wiz_equip
                WHERE serial_number = isc_serial_number;
            EXCEPTION
               WHEN OTHERS THEN
                  odurum := 'EKIPMAN SISTEMDE KAYITLI DEGIL.EKIPMAN NO:' || isc_serial_number;
                  RETURN;
            END;
         END IF;

         IF    (TRIM (v_sc_converter_type) IS NOT NULL AND TRIM (v_stb_converter_type) IS NOT NULL AND TRIM (v_sc_converter_type) = TRIM (v_stb_converter_type))
            OR (TRIM (v_sc_converter_type) IS NOT NULL AND TRIM (v_md_converter_type) IS NOT NULL AND TRIM (v_sc_converter_type) = TRIM (v_md_converter_type))
            OR (TRIM (v_md_converter_type) IS NOT NULL AND TRIM (v_stb_converter_type) IS NOT NULL AND TRIM (v_md_converter_type) = TRIM (v_stb_converter_type)) THEN
            odurum := 'IADEDE KULLANILAN EKIPMAN TIPLERI AYNI.';
            RETURN;
         END IF;

         IF    (    TRIM (v_sc_outlet_location) IS NOT NULL
                AND TRIM (v_stb_outlet_location) IS NOT NULL
                AND TRIM (v_sc_outlet_location) <> TRIM (v_stb_outlet_location))
            OR (    TRIM (v_sc_outlet_location) IS NOT NULL
                AND TRIM (v_md_outlet_location) IS NOT NULL
                AND TRIM (v_sc_outlet_location) <> TRIM (v_md_outlet_location))
            OR (    TRIM (v_md_outlet_location) IS NOT NULL
                AND TRIM (v_stb_outlet_location) IS NOT NULL
                AND TRIM (v_md_outlet_location) <> TRIM (v_stb_outlet_location)) THEN
            odurum := 'IADEDE KULLANILAN EKIPMAN OUTLETLERI FARKLI.';
            RETURN;
         END IF;

         IF TRIM (isc_serial_number) IS NOT NULL AND TRIM (istb_serial_number) IS NOT NULL AND TRIM (isc_serial_number) = TRIM (istb_serial_number) THEN
            odurum := 'SC ve STB EKIPMAN NUMARALARI AYNI OLAMAZ.';
            RETURN;
         END IF;

         IF TRIM (isc_serial_number) IS NOT NULL AND TRIM (imd_serial_number) IS NOT NULL AND TRIM (isc_serial_number) = TRIM (imd_serial_number) THEN
            odurum := 'SC ve MODUL EKIPMAN NUMARALARI AYNI OLAMAZ.';
            RETURN;
         END IF;

         IF TRIM (imd_serial_number) IS NOT NULL AND TRIM (istb_serial_number) IS NOT NULL AND TRIM (imd_serial_number) = TRIM (istb_serial_number) THEN
            odurum := 'MODUL ve STB EKIPMAN NUMARALARI AYNI OLAMAZ.';
            RETURN;
         END IF;
      END IF;

      IF iislem_tipi = 'EKIPMAN_DEGISIM' -- its_servis artık kullanılmadığı için buraa modül geliştirilmesi eklenmedi. Falamur
                                        THEN
      /* #BAHADIR ŞENYAYLA 2015.01.09 
      EĞER ÜYENİN 430 VE ÜYENİN GÜNCEL SERVİSİ DEĞİL İSE EKİPMAN DEĞİŞİMİ YAPILMAYACAK */
    
          IF TRIM(iuye_no) IS NOT NULL THEN
                SELECT COUNT(*)
                INTO v_count 
                FROM DBS_DBA.MB_ABONE_OZELLIK ABN
                WHERE ABN.ACCOUNT_NUMBER=iuye_no
                AND ABN.ABONE_OZELLIK_KODU =430;
                
                v_sales_agent_code:=DBS_DBA.BT_UYE_TS_PACK.BT_UYE_TS_FIND(iuye_no,ioutlet_location,1);
                
               IF  ((its_no<>v_sales_agent_code) AND (v_count > 0)) THEN
                    odurum := 'ÜYENİN 430 KODU BBULUNDUĞU İÇİN YADA ÜYENİN GÜNCEL SERVİSİ DEĞİL İSE , EKİPMAN DEĞİŞİMİ YAPILAMAZ.';
                    RETURN;
               END IF ;
          END IF;
                                        
                                        
                                        
         IF TRIM (iotorizasyon_no) IS NOT NULL AND v_iris_kullanici = 0 THEN
            BEGIN
               SELECT x.eski_stb_seri_no, x.ts_no, x.stb_seri_no, x.uye_eski_sc_seri_no, x.uye_no, x.uye_sc_seri_no
                 INTO x_eski_stb_seri_no, x_ts_no, x_stb_seri_no, x_uye_eski_sc_seri_no, x_uye_no, x_uye_sc_seri_no
                 FROM its_servis x
                WHERE kayit_no = TRIM (iotorizasyon_no);
            EXCEPTION
               WHEN OTHERS THEN
                  odurum := 'ITS KAYDI BULUNAMADI.OTORIZASYON NO:' || TRIM (iotorizasyon_no);
                  RETURN;
            END;

            IF TRIM (x_ts_no) <> TRIM (its_no) THEN
               odurum := 'ITS KAYDI ILE TS NO UYUMLU DEGIL.';
               RETURN;
            END IF;

            IF ialt_islem_tipi = 'SC_DEGISIM' THEN
               IF TRIM (x_uye_eski_sc_seri_no) IS NOT NULL AND TRIM (x_uye_eski_sc_seri_no) <> TRIM (isc_serial_number) THEN
                  odurum := 'ITS KAYDI ILE UYE ESKI SC NO UYUMLU DEGIL.' || TRIM (x_uye_eski_sc_seri_no);
                  RETURN;
               END IF;

               IF TRIM (iuye_no) IS NOT NULL AND TRIM (x_uye_eski_sc_seri_no) IS NOT NULL THEN
                  SELECT COUNT (1)
                    INTO v_count
                    FROM lg_ekipman
                   WHERE account_number = TRIM (iuye_no) AND serial_number = TRIM (x_uye_eski_sc_seri_no);

                  IF v_count = 0 THEN
                     odurum := 'ITS KAYDI ILE UYE ESKI SC NO VE UYE NO UYUMLU DEGIL.';
                     RETURN;
                  END IF;
               END IF;
            /*
                 ELSE
                    if trim(iuye_no) is not null and trim(x_eski_stb_seri_no) is not null then
                        select count(1)
                        into v_count
                        from lg_ekipman
                        where account_number = trim(iuye_no)
                        and serial_number = trim(x_eski_stb_seri_no);

                      if v_count = 0 then
                        odurum := 'ITS KAYDI ILE UYE ESKI STB NO VE UYE NO UYUMLU DEGIL.';
                        return;
                       end if;
                    end if;
            */
            END IF;
         END IF;
      ELSIF iislem_tipi = 'EKIPMAN_IADE' THEN
         IF TRIM (iotorizasyon_no) IS NOT NULL THEN
            BEGIN
               SELECT x.stb_seri_no, x.ts_no, x.uye_sc_seri_no, x.uye_no
                 INTO x_stb_seri_no, x_ts_no, x_uye_sc_seri_no, x_uye_no
                 FROM its_iade x
                WHERE kayit_no = TRIM (iotorizasyon_no);
            EXCEPTION
               WHEN OTHERS THEN
                  odurum := 'ITS KAYDI BULUNAMADI.OTORIZASYON NO:' || TRIM (iotorizasyon_no);
                  RETURN;
            END;

            IF TRIM (x_ts_no) <> TRIM (its_no) THEN
               odurum := 'ITS KAYDI ILE TS NO UYUMLU DEGIL.';
               RETURN;
            END IF;
         END IF;
      END IF;
   END tlf_ekipman_islemi_yapilabilir;

   PROCEDURE lg_telefon_ekipm_islem_ins_upd (in_islem_tipi                 IN     lg_telefon_ekipman_islemleri.islem_tipi%TYPE,
                                             in_alt_islem_tipi             IN     lg_telefon_ekipman_islemleri.alt_islem_tipi%TYPE,
                                             in_otorizasyon_no             IN     lg_telefon_ekipman_islemleri.otorizasyon_no%TYPE,
                                             in_lg_teknik_servis_sifre_id  IN     lg_telefon_ekipman_islemleri.lg_teknik_servis_sifre_id%TYPE,
                                             in_sales_agent_code           IN     lg_telefon_ekipman_islemleri.sales_agent_code%TYPE,
                                             in_sc_equip_location_code     IN     lg_telefon_ekipman_islemleri.sc_equip_location_code%TYPE,
                                             in_stb_equip_location_code    IN     lg_telefon_ekipman_islemleri.stb_equip_location_code%TYPE,
                                             in_md_equip_location_code     IN     lg_telefon_ekipman_islemleri.md_equip_location_code%TYPE,
                                             in_account_number             IN     lg_telefon_ekipman_islemleri.account_number%TYPE,
                                             in_outlet_location            IN     lg_telefon_ekipman_islemleri.outlet_location%TYPE,
                                             in_sc_serial_number           IN     lg_telefon_ekipman_islemleri.sc_serial_number%TYPE,
                                             in_stb_serial_number          IN     lg_telefon_ekipman_islemleri.stb_serial_number%TYPE,
                                             in_md_serial_number           IN     lg_telefon_ekipman_islemleri.md_serial_number%TYPE,
                                             in_new_sc_serial_number       IN     lg_telefon_ekipman_islemleri.new_sc_serial_number%TYPE,
                                             in_new_stb_serial_number      IN     lg_telefon_ekipman_islemleri.new_stb_serial_number%TYPE,
                                             in_new_md_serial_number       IN     lg_telefon_ekipman_islemleri.new_md_serial_number%TYPE,
                                             in_hatali_sc_serial_number    IN     lg_telefon_ekipman_islemleri.new_stb_serial_number%TYPE,
                                             in_hatali_stb_serial_number   IN     lg_telefon_ekipman_islemleri.new_stb_serial_number%TYPE,
                                             in_hatali_md_serial_number    IN     lg_telefon_ekipman_islemleri.new_md_serial_number%TYPE,
                                             in_sc_kayip                   IN     lg_telefon_ekipman_islemleri.sc_kayip%TYPE,
                                             in_stb_kayip                  IN     lg_telefon_ekipman_islemleri.stb_kayip%TYPE,
                                             in_md_kayip                   IN     lg_telefon_ekipman_islemleri.stb_kayip%TYPE,
                                             in_ts_form_no                 IN     lg_telefon_ekipman_islemleri.ts_form_no%TYPE,
                                             in_aciklama                   IN     lg_telefon_ekipman_islemleri.aciklama%TYPE,
                                             in_sc_ekipm_uyeye_atildi      IN     lg_telefon_ekipman_islemleri.sc_ekipm_uyeye_atildi%TYPE,
                                             in_hatali_sc_inv_depo_atildi  IN     lg_telefon_ekipman_islemleri.hatali_sc_inv_depo_atildi%TYPE,
                                             in_sc_ekipm_yts_kayip_atildi  IN     lg_telefon_ekipman_islemleri.sc_ekipm_yts_kayip_atildi%TYPE,
                                             in_stb_ekipm_uyeye_atildi     IN     lg_telefon_ekipman_islemleri.stb_ekipm_uyeye_atildi%TYPE,
                                             in_hatali_stb_inv_depo_atildi IN     lg_telefon_ekipman_islemleri.hatali_stb_inv_depo_atildi%TYPE,
                                             in_stb_ekipm_yts_kayip_atildi IN     lg_telefon_ekipman_islemleri.stb_ekipm_yts_kayip_atildi%TYPE,
                                             in_md_ekipm_uyeye_atildi      IN     lg_telefon_ekipman_islemleri.md_ekipm_uyeye_atildi%TYPE,
                                             in_hatali_md_inv_depo_atildi  IN     lg_telefon_ekipman_islemleri.hatali_md_inv_depo_atildi%TYPE,
                                             in_md_ekipm_yts_kayip_atildi  IN     lg_telefon_ekipman_islemleri.md_ekipm_yts_kayip_atildi%TYPE,
                                             in_kisi                       IN     lg_telefon_ekipman_islemleri.kisi%TYPE,
                                             durum                            OUT VARCHAR2
                                            ) IS
      v_islem_tipi                 lg_telefon_ekipman_islemleri.islem_tipi%TYPE;
      v_alt_islem_tipi             lg_telefon_ekipman_islemleri.alt_islem_tipi%TYPE;
      v_otorizasyon_no             lg_telefon_ekipman_islemleri.otorizasyon_no%TYPE;
      v_lg_teknik_servis_sifre_id  lg_telefon_ekipman_islemleri.lg_teknik_servis_sifre_id%TYPE;
      v_sales_agent_code           lg_telefon_ekipman_islemleri.sales_agent_code%TYPE;
      v_sc_equip_location_code     lg_telefon_ekipman_islemleri.sc_equip_location_code%TYPE;
      v_stb_equip_location_code    lg_telefon_ekipman_islemleri.stb_equip_location_code%TYPE;
      v_md_equip_location_code     lg_telefon_ekipman_islemleri.md_equip_location_code%TYPE;
      v_account_number             lg_telefon_ekipman_islemleri.account_number%TYPE;
      v_outlet_location            lg_telefon_ekipman_islemleri.outlet_location%TYPE;
      v_sc_serial_number           lg_telefon_ekipman_islemleri.sc_serial_number%TYPE;
      v_stb_serial_number          lg_telefon_ekipman_islemleri.stb_serial_number%TYPE;
      v_md_serial_number           lg_telefon_ekipman_islemleri.md_serial_number%TYPE;
      v_new_sc_serial_number       lg_telefon_ekipman_islemleri.new_sc_serial_number%TYPE;
      v_new_stb_serial_number      lg_telefon_ekipman_islemleri.new_stb_serial_number%TYPE;
      v_new_md_serial_number       lg_telefon_ekipman_islemleri.new_md_serial_number%TYPE;
      v_hatali_sc_serial_number    lg_telefon_ekipman_islemleri.new_stb_serial_number%TYPE;
      v_hatali_stb_serial_number   lg_telefon_ekipman_islemleri.new_stb_serial_number%TYPE;
      v_hatali_md_serial_number    lg_telefon_ekipman_islemleri.new_md_serial_number%TYPE;
      v_sc_kayip                   lg_telefon_ekipman_islemleri.sc_kayip%TYPE;
      v_stb_kayip                  lg_telefon_ekipman_islemleri.stb_kayip%TYPE;
      v_md_kayip                   lg_telefon_ekipman_islemleri.md_kayip%TYPE;
      v_ts_form_no                 lg_telefon_ekipman_islemleri.ts_form_no%TYPE;
      v_aciklama                   lg_telefon_ekipman_islemleri.aciklama%TYPE;
      v_sc_ekipm_uyeye_atildi      lg_telefon_ekipman_islemleri.sc_ekipm_uyeye_atildi%TYPE;
      v_hatali_sc_inv_depo_atildi  lg_telefon_ekipman_islemleri.hatali_sc_inv_depo_atildi%TYPE;
      v_sc_ekipm_yts_kayip_atildi  lg_telefon_ekipman_islemleri.sc_ekipm_yts_kayip_atildi%TYPE;
      v_stb_ekipm_uyeye_atildi     lg_telefon_ekipman_islemleri.stb_ekipm_uyeye_atildi%TYPE;
      v_hatali_stb_inv_depo_atildi lg_telefon_ekipman_islemleri.hatali_stb_inv_depo_atildi%TYPE;
      v_stb_ekipm_yts_kayip_atildi lg_telefon_ekipman_islemleri.stb_ekipm_yts_kayip_atildi%TYPE;
      v_md_ekipm_uyeye_atildi      lg_telefon_ekipman_islemleri.md_ekipm_uyeye_atildi%TYPE;
      v_hatali_md_inv_depo_atildi  lg_telefon_ekipman_islemleri.hatali_md_inv_depo_atildi%TYPE;
      v_md_ekipm_yts_kayip_atildi  lg_telefon_ekipman_islemleri.md_ekipm_yts_kayip_atildi%TYPE;
      v_kisi                       lg_telefon_ekipman_islemleri.kisi%TYPE;
   BEGIN
      durum                        := '0';
      v_islem_tipi                 := TRIM (in_islem_tipi);
      v_alt_islem_tipi             := TRIM (in_alt_islem_tipi);
      v_otorizasyon_no             := TRIM (in_otorizasyon_no);
      v_lg_teknik_servis_sifre_id  := TRIM (in_lg_teknik_servis_sifre_id);
      v_sales_agent_code           := TRIM (in_sales_agent_code);
      v_sc_equip_location_code     := TRIM (in_sc_equip_location_code);
      v_stb_equip_location_code    := TRIM (in_stb_equip_location_code);
      v_md_equip_location_code     := TRIM (in_md_equip_location_code);
      v_account_number             := TRIM (in_account_number);
      v_outlet_location            := TRIM (in_outlet_location);
      v_sc_serial_number           := TRIM (in_sc_serial_number);
      v_stb_serial_number          := TRIM (in_stb_serial_number);
      v_md_serial_number           := TRIM (in_md_serial_number);
      v_new_sc_serial_number       := TRIM (in_new_sc_serial_number);
      v_new_stb_serial_number      := TRIM (in_new_stb_serial_number);
      v_new_md_serial_number       := TRIM (in_new_md_serial_number);
      v_sc_kayip                   := TRIM (in_sc_kayip);
      v_stb_kayip                  := TRIM (in_stb_kayip);
      v_md_kayip                   := TRIM (in_md_kayip);
      v_ts_form_no                 := TRIM (in_ts_form_no);
      v_aciklama                   := TRIM (in_aciklama);
      v_sc_ekipm_uyeye_atildi      := TRIM (in_sc_ekipm_uyeye_atildi);
      v_hatali_sc_inv_depo_atildi  := TRIM (in_hatali_sc_inv_depo_atildi);
      v_sc_ekipm_yts_kayip_atildi  := TRIM (in_sc_ekipm_yts_kayip_atildi);
      v_stb_ekipm_uyeye_atildi     := TRIM (in_stb_ekipm_uyeye_atildi);
      v_hatali_stb_inv_depo_atildi := TRIM (in_hatali_stb_inv_depo_atildi);
      v_stb_ekipm_yts_kayip_atildi := TRIM (in_stb_ekipm_yts_kayip_atildi);
      v_md_ekipm_uyeye_atildi      := TRIM (in_md_ekipm_uyeye_atildi);
      v_hatali_md_inv_depo_atildi  := TRIM (in_hatali_md_inv_depo_atildi);
      v_md_ekipm_yts_kayip_atildi  := TRIM (in_md_ekipm_yts_kayip_atildi);
      v_kisi                       := TRIM (in_kisi);
      v_hatali_sc_serial_number    := TRIM (in_hatali_sc_serial_number);
      v_hatali_stb_serial_number   := TRIM (in_hatali_stb_serial_number);
      v_hatali_md_serial_number    := TRIM (in_hatali_md_serial_number);

      INSERT
        INTO lg_telefon_ekipman_islemleri (id,
                                           islem_tipi,
                                           alt_islem_tipi,
                                           otorizasyon_no,
                                           lg_teknik_servis_sifre_id,
                                           sales_agent_code,
                                           sc_equip_location_code,
                                           stb_equip_location_code,
                                           md_equip_location_code,
                                           account_number,
                                           outlet_location,
                                           sc_serial_number,
                                           stb_serial_number,
                                           md_serial_number,
                                           new_sc_serial_number,
                                           new_stb_serial_number,
                                           new_md_serial_number,
                                           sc_kayip,
                                           stb_kayip,
                                           md_kayip,
                                           ts_form_no,
                                           aciklama,
                                           sc_ekipm_uyeye_atildi,
                                           hatali_sc_inv_depo_atildi,
                                           sc_ekipm_yts_kayip_atildi,
                                           stb_ekipm_uyeye_atildi,
                                           hatali_stb_inv_depo_atildi,
                                           stb_ekipm_yts_kayip_atildi,
                                           md_ekipm_uyeye_atildi,
                                           hatali_md_inv_depo_atildi,
                                           md_ekipm_yts_kayip_atildi,
                                           kisi,
                                           islem_tarihi,
                                           hatali_sc_serial_number,
                                           hatali_stb_serial_number,
                                           hatali_md_serial_number
                                          )
         VALUES (
                   lg_tlf_ekipman_islem_id_seq.NEXTVAL,
                   v_islem_tipi,
                   v_alt_islem_tipi,
                   v_otorizasyon_no,
                   v_lg_teknik_servis_sifre_id,
                   v_sales_agent_code,
                   v_sc_equip_location_code,
                   v_stb_equip_location_code,
                   v_md_equip_location_code,
                   v_account_number,
                   v_outlet_location,
                   v_sc_serial_number,
                   v_stb_serial_number,
                   v_md_serial_number,
                   v_new_sc_serial_number,
                   v_new_stb_serial_number,
                   v_new_md_serial_number,
                   NVL (v_sc_kayip, 'H'),
                   NVL (v_stb_kayip, 'H'),
                   NVL (v_md_kayip, 'H'),
                   v_ts_form_no,
                   v_aciklama,
                   NVL (v_sc_ekipm_uyeye_atildi, 'H'),
                   NVL (v_hatali_sc_inv_depo_atildi, 'H'),
                   NVL (v_sc_ekipm_yts_kayip_atildi, 'H'),
                   NVL (v_stb_ekipm_uyeye_atildi, 'H'),
                   NVL (v_hatali_stb_inv_depo_atildi, 'H'),
                   NVL (v_stb_ekipm_yts_kayip_atildi, 'H'),
                   NVL (v_md_ekipm_uyeye_atildi, 'H'),
                   NVL (v_hatali_md_inv_depo_atildi, 'H'),
                   NVL (v_md_ekipm_yts_kayip_atildi, 'H'),
                   v_kisi,
                   SYSDATE,
                   v_hatali_sc_serial_number,
                   v_hatali_stb_serial_number,
                   v_hatali_md_serial_number);
   EXCEPTION
      WHEN OTHERS THEN
         durum := SQLERRM;
   END;

   PROCEDURE telefon_ekipman_iade (iotorizasyon_no            IN     its_servis.kayit_no%TYPE,
                                   ilg_teknik_servis_sifre_id IN     lg_teknik_servis_sifre.id%TYPE,
                                   its_no                     IN     lg_ekipman.sales_agent_code%TYPE,
                                   istb_depo_kodu             IN     lg_ekipman.depoya%TYPE,
                                   imd_depo_kodu              IN     lg_ekipman.depoya%TYPE,
                                   isc_depo_kodu              IN     lg_ekipman.depoya%TYPE,
                                   iuye_no                    IN     wiz_equip.account_number%TYPE,
                                   ioutlet_location           IN     wiz_equip.outlet_location%TYPE,
                                   istb_serial_number         IN     wiz_equip.serial_number%TYPE,
                                   imd_serial_number          IN     wiz_equip.serial_number%TYPE,
                                   isc_serial_number          IN     wiz_equip.serial_number%TYPE,
                                   istb_kayip                 IN     CHAR,
                                   imd_kayip                  IN     CHAR,
                                   isc_kayip                  IN     CHAR,
                                   its_form_no                IN     lg_ekipman.ts_form_no%TYPE,
                                   in_aciklama                IN     lg_ekipman.aciklama%TYPE,
                                   igiren_kullanici           IN     co_kullanici.kod%TYPE,
                                   iok                        IN     VARCHAR2 := '0:E',
                                   odurum                        OUT VARCHAR2,
                                   oproc_name                    OUT VARCHAR2
                                  ) IS
      v_ret                         NUMBER;
      v_stb_outlet_location         wiz_equip.outlet_location%TYPE;
      v_md_outlet_location          wiz_equip.outlet_location%TYPE;
      v_sc_outlet_location          wiz_equip.outlet_location%TYPE;
      v_stb_converter_type          wiz_equip.converter_type%TYPE;
      -- v_md_converter_type             wiz_equip.converter_type%TYPE;
      v_md_converter_type           VARCHAR2 (3);
      v_sc_converter_type           wiz_equip.converter_type%TYPE;
      v_stb_equip_location_code     wiz_equip.equip_location_code%TYPE;
      v_md_equip_location_code      wiz_equip.equip_location_code%TYPE;
      v_sc_equip_location_code      wiz_equip.equip_location_code%TYPE;
      v_stb_uye_no                  wiz_equip.account_number%TYPE;
      v_md_uye_no                   wiz_equip.account_number%TYPE;
      v_sc_uye_no                   wiz_equip.account_number%TYPE;
      v_stb_depo_kayip_count        NUMBER := 0;
      v_md_depo_kayip_count         NUMBER := 0;
      v_sc_depo_kayip_count         NUMBER := 0;
      v_yeni_stb_depo_kayip_count   NUMBER := 0;
      v_yeni_md_depo_kayip_count    NUMBER := 0;
      v_yeni_sc_depo_kayip_count    NUMBER := 0;
      v_hatali_sc_serial_number     wiz_equip.serial_number%TYPE;
      v_hatali_stb_serial_number    wiz_equip.serial_number%TYPE;
      v_hatali_md_serial_number     wiz_equip.serial_number%TYPE;
      beski_ekipm_uyeye_at          BOOLEAN := FALSE;
      bhatali_ekipm_inv_deposuna_at BOOLEAN := FALSE;
      beski_ekipm_yts_kayip_depo_at BOOLEAN := FALSE;
      buyenin_tek_outleti_var       BOOLEAN := FALSE;
      v_sc_ekipm_uyeye_atildi       CHAR (1) := 'H';
      v_hatali_sc_inv_depo_at       CHAR (1) := 'H';
      v_sc_ekipm_yts_kayip_at       CHAR (1) := 'H';
      v_stb_ekipm_uyeye_atildi      CHAR (1) := 'H';
      v_hatali_stb_inv_depo_at      CHAR (1) := 'H';
      v_stb_ekipm_yts_kayip_at      CHAR (1) := 'H';
      v_md_ekipm_uyeye_atildi       CHAR (1) := 'H';
      v_hatali_md_inv_depo_at       CHAR (1) := 'H';
      v_md_ekipm_yts_kayip_at       CHAR (1) := 'H';
      v_service_address_id          wiz_customer_hp_life.service_address_id%TYPE;
      ois_emri                      NUMBER (10); --wiz_work_order.work_order_number%TYPE;
      v_count                       NUMBER := 0;
      yyetki_ekipmani_uyeye_atama   NUMBER := 0;
      v_error_type                  NUMBER (1);
      v_error_code                  VARCHAR2 (10);
      v_error_text                  VARCHAR2 (512);
      v_taa_uyari                   VARCHAR2 (512);
      v_iris_kullanici              NUMBER := 0;
      v_reason_code                 lg_ekipman.depoya%TYPE := 'YTL';
      vekipman_modul_tipi           NUMBER;
      oeq_ekipman_id                NUMBER;
   BEGIN
      odurum                      := 'FAILED';
      oproc_name                  := 'TELEFON_EKIPMAN_IADE';

      IF igiren_kullanici IN ('SYSIRIS', 'SYSIVR') THEN
         v_iris_kullanici := 1;
         v_reason_code    := 'INT';
      END IF;

      v_stb_outlet_location       := TRIM (ioutlet_location);
      v_md_outlet_location        := TRIM (ioutlet_location);
      v_sc_outlet_location        := TRIM (ioutlet_location);
      yyetki_ekipmani_uyeye_atama := yetki_pack.yetkisi_varmi (igiren_kullanici, 'ISLEM_EKIPMANI_DUZELTME_ICIN_UYEYE_ATAMA');

      IF TRIM (istb_serial_number) IS NOT NULL THEN
         BEGIN
            SELECT outlet_location, converter_type, account_number, equip_location_code
              INTO v_stb_outlet_location, v_stb_converter_type, v_stb_uye_no, v_stb_equip_location_code
              FROM wiz_equip
             WHERE serial_number = istb_serial_number;

            IF v_stb_uye_no > 0 AND v_stb_uye_no <> iuye_no THEN
               odurum     := 'STB EKIPMAN BASKA BIR ÜYEDE.';
               oproc_name := 'TELEFON_EKIPMAN_IADE';
               RETURN;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               odurum     := 'STB EKIPMAN TANIMLI DEGIL.';
               oproc_name := 'TELEFON_EKIPMAN_IADE';
               RETURN;
         END;
      END IF;

      IF TRIM (imd_serial_number) IS NOT NULL THEN
         BEGIN
            SELECT outlet_location, TRIM (ekipman_tipi), account_number, equip_location_code
              INTO v_md_outlet_location, v_md_converter_type, v_md_uye_no, v_md_equip_location_code
              FROM eq_ekipman
             WHERE serial_number = imd_serial_number;

            IF v_md_uye_no > 0 AND v_md_uye_no <> iuye_no THEN
               odurum     := 'MODUL EKIPMAN BASKA BIR ÜYEDE.';
               oproc_name := 'TELEFON_EKIPMAN_IADE';
               RETURN;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               odurum     := 'MODUL EKIPMAN TANIMLI DEGIL. seri_no:' || imd_serial_number || SQLERRM;
               oproc_name := 'TELEFON_EKIPMAN_IADE';
               RETURN;
         END;
      END IF;

      IF TRIM (isc_serial_number) IS NOT NULL THEN
         BEGIN
            SELECT outlet_location, converter_type, account_number, equip_location_code
              INTO v_sc_outlet_location, v_sc_converter_type, v_sc_uye_no, v_sc_equip_location_code
              FROM wiz_equip
             WHERE serial_number = isc_serial_number;

            IF v_sc_uye_no > 0 AND v_sc_uye_no <> iuye_no THEN
               odurum     := 'SC EKIPMAN BASKA BIR ÜYEDE.';
               oproc_name := 'TELEFON_EKIPMAN_IADE';
               RETURN;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               odurum     := 'SC EKIPMAN TANIMLI DEGIL.';
               oproc_name := 'TELEFON_EKIPMAN_IADE';
               RETURN;
         END;
      END IF;

      v_count                     := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM eq_ekipman_sahibi_kim
       WHERE     (serial_number = istb_serial_number OR serial_number = isc_serial_number OR serial_number = imd_serial_number)
             AND kayit_iptal = 'H'
             AND ekipman_sahibi_tipi = 1
             AND sahiplik_tipi = 0;

      IF v_count > 0 THEN
         odurum     := 'Satin alinmis ekipman iade edilemez.';
         oproc_name := 'TELEFON_EKIPMAN_IADE';
         RETURN;
      END IF;

      FOR rec
         IN (SELECT *
               FROM eq_ekipman_sahibi_kim
              WHERE     (serial_number = istb_serial_number OR serial_number = imd_serial_number OR serial_number = isc_serial_number)
                    AND kayit_iptal = 'H'
                    AND ekipman_sahibi_tipi = 1
                    AND sahiplik_tipi = 1) LOOP
         UPDATE eq_ekipman_sahibi_kim
            SET kayit_iptal          = 'E',
                iptal_sebep_kodu     = v_reason_code,
                aciklama             = in_aciklama,
                degistiren_kullanici = igiren_kullanici,
                degistirme_tarihi    = SYSDATE
          WHERE serial_number = rec.serial_number;

         lg_ekipman_sahibi_kim_insert ('U',
                                       igiren_kullanici,
                                       rec.serial_number,
                                       rec.account_number,
                                       rec.outlet_location,
                                       rec.sales_agent_code,
                                       rec.sebep_kodu,
                                       rec.ekipman_sahibi_tipi,
                                       in_aciklama,
                                       v_reason_code,
                                       'E',
                                       rec.kampanya_kodu,
                                       rec.satis_bayi_kodu,
                                       rec.kampanya_ozellik_kodu,
                                       rec.kampanya_ozellik_degeri,
                                       rec.sahiplik_tipi,
                                       rec.ekipman_tipi,
                                       rec.sahiplik_id,
                                       rec.garanti_baslangic,
                                       odurum
                                      );

         IF TRIM (odurum) <> '0' THEN
            odurum     := 'lg_ekipman_sahibi_kim :' || odurum;
            oproc_name := 'TELEFON_EKIPMAN_IADE';
            RETURN;
         END IF;
      END LOOP;

      BEGIN
         SELECT service_address_id
           INTO v_service_address_id
           FROM wiz_customer_hp_life
          WHERE account_number = iuye_no;
      EXCEPTION
         WHEN OTHERS THEN
            odurum     := 'ÜYE KAYDI BULUNAMADI.';
            oproc_name := 'TELEFON_EKIPMAN_IADE';
            RETURN;
      END;

      --SC depo kontrolleri
      --yeni depo kayip deposu mu yoksa YTS deposu mu
      IF isc_depo_kodu IS NOT NULL THEN
         SELECT COUNT (1)
           INTO v_sc_depo_kayip_count
           FROM wiz_equip_location_codes
          WHERE ust_depo_kod = 'KAYIP/CALINTI' AND equip_location_code = isc_depo_kodu;

         IF isc_kayip = 'H' THEN
            IF v_sc_depo_kayip_count > 0 THEN
               odurum     := 'SC EKIPMAN KAYIP OLARAK ISARETLENMEMIS FAKAT DEPO KODU KAYIP ÇALINTI SEÇILMIS.';
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            END IF;
         ELSIF isc_kayip = 'E' THEN
            IF v_sc_depo_kayip_count = 0 THEN
               odurum     := 'SC EKIPMAN KAYIP OLARAK ISARETLENMIS FAKAT DEPO KODU YTS KODU SEÇILMIS.';
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            END IF;
         END IF;
      END IF;

      --STB depo kontrolleri
      --yeni depo kayip deposu mu yoksa YTS deposu mu
      IF istb_depo_kodu IS NOT NULL THEN
         SELECT COUNT (1)
           INTO v_stb_depo_kayip_count
           FROM wiz_equip_location_codes
          WHERE ust_depo_kod = 'KAYIP/CALINTI' AND equip_location_code = istb_depo_kodu;

         IF istb_kayip = 'H' THEN
            IF v_stb_depo_kayip_count > 0 THEN
               odurum     := 'STB EKIPMAN KAYIP OLARAK ISARETLENMEMIS FAKAT DEPO KODU KAYIP ÇALINTI SEÇILMIS.';
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            END IF;
         ELSIF istb_kayip = 'E' THEN
            IF v_stb_depo_kayip_count = 0 THEN
               odurum     := 'STB EKIPMAN KAYIP OLARAK ISARETLENMIS FAKAT DEPO KODU YTS KODU SEÇILMIS.';
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            END IF;
         END IF;
      END IF;

      --MODUL depo kontrolleri
      --yeni depo kayip deposu mu yoksa YTS deposu mu
      IF imd_depo_kodu IS NOT NULL THEN
         SELECT COUNT (1)
           INTO v_md_depo_kayip_count
           FROM wiz_equip_location_codes
          WHERE ust_depo_kod = 'KAYIP/CALINTI' AND equip_location_code = imd_depo_kodu;

         IF imd_kayip = 'H' THEN
            IF v_md_depo_kayip_count > 0 THEN
               odurum     := 'MODUL EKIPMAN KAYIP OLARAK ISARETLENMEMIS FAKAT DEPO KODU KAYIP ÇALINTI SEÇILMIS.';
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            END IF;
         ELSIF imd_kayip = 'E' THEN
            IF v_md_depo_kayip_count = 0 THEN
               odurum     := 'MODUL EKIPMAN KAYIP OLARAK ISARETLENMIS FAKAT DEPO KODU YTS KODU SEÇILMIS.';
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            END IF;
         END IF;
      END IF;

      --SC islemleri
      --eski ekipman dogru üyede
      ----------------------------------
      IF TRIM (isc_serial_number) IS NOT NULL THEN
         IF v_sc_uye_no = iuye_no THEN
            --Eski ekipmanin durumuna göre
            --YTS deposuna atilir
            --KAYIP deposuna atilir
            beski_ekipm_uyeye_at          := FALSE;
            bhatali_ekipm_inv_deposuna_at := FALSE;
            beski_ekipm_yts_kayip_depo_at := TRUE;
         --eski ekipman dogru üyede degil veya depoda
         -----------------------------------------------
         ELSE
            --eski ekipman kayip çalinti deposunda mi?
            IF TRIM (v_sc_equip_location_code) IS NOT NULL AND v_sc_uye_no = 0 THEN
               SELECT COUNT (1)
                 INTO v_sc_depo_kayip_count
                 FROM wiz_equip_location_codes
                WHERE ust_depo_kod = 'KAYIP/CALINTI' AND equip_location_code = v_sc_equip_location_code;
            ELSIF TRIM (v_sc_equip_location_code) IS NOT NULL THEN
               odurum     := 'ÜYE BILGISI VE LOKASYON KODU ELDE EDILEMEDI.';
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            END IF;

            --outlet bilgisi yok ise bul...
            IF TRIM (ioutlet_location) IS NULL THEN
               SELECT COUNT (DISTINCT (outlet_location))
                 INTO v_count
                 FROM wiz_equip
                WHERE account_number = iuye_no;

               IF v_count > 1 THEN
                  odurum     := 'ÜYENIN BIRDEN FAZLA OUTLETI VAR. OUTLET SEÇINIZ.';
                  oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
                  RETURN;
               ELSIF v_count = 0 THEN
                  odurum     := 'ÜYENIN OUTLETI ELDE EDILEMEDI. OUTLET SEÇINIZ.';
                  oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
                  RETURN;
               ELSE
                  --üyenin tek outleti var o kullanilacak
                  --problem yok
                  buyenin_tek_outleti_var := TRUE;
               END IF;
            --outlet bilgisi var ise bulunan ile uyumlu mu?
            ELSIF TRIM (v_sc_outlet_location) IS NOT NULL AND (TRIM (ioutlet_location) <> TRIM (v_sc_outlet_location)) THEN
               odurum     := 'ÜYE OUTLETI ILE EKIPMAN OUTLETI FARKLI.DOGRU OUTLETI SEÇINIZ.';
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            --outlet bilgisi var, ekrandan girilmis ve o kullanilacak ise
            --problem yok o outleti kontrol et
            ELSE
               NULL;
            END IF;
         END IF;

         --varolan tek bir outletten islem yapilabilir durumda
         --isleme devam et
         IF (v_sc_uye_no <> iuye_no) AND (buyenin_tek_outleti_var OR TRIM (ioutlet_location) IS NOT NULL) THEN
            BEGIN
               IF TRIM (ioutlet_location) IS NULL THEN
                  SELECT serial_number, outlet_location
                    INTO v_hatali_sc_serial_number, v_sc_outlet_location
                    FROM wiz_equip
                   WHERE account_number = iuye_no AND converter_type = v_sc_converter_type;
               ELSE
                  SELECT serial_number
                    INTO v_hatali_sc_serial_number
                    FROM wiz_equip
                   WHERE account_number = iuye_no AND outlet_location = TRIM (ioutlet_location) AND converter_type = v_sc_converter_type;
               END IF;

               --baska bir ekipman o outlette var ise
               --üyedeki ekipman INV deposuna atilir
               --beyan edilen ekipman üyeye verilir
               --sonra YTS deposuna atilir
               --yeni ekipman üyeye verilir

               --eski ekipman baska üyede
               ----------------------------------
               IF v_sc_uye_no > 0 AND v_sc_uye_no <> iuye_no THEN
                  --eski ekipman baska üyede ve YTS deposu
                  --eski ekipman baska üyede ve kayip deposu
                  --yeni ekipman üyeye verilir
                  beski_ekipm_uyeye_at          := FALSE;
                  bhatali_ekipm_inv_deposuna_at := TRUE;
                  beski_ekipm_yts_kayip_depo_at := FALSE;
               END IF;

               --eski ekipman YTS deposunda ve kayip degil
               --ya da
               --eski ekipman YTS deposunda ve kayip
               IF v_sc_uye_no = 0 AND v_sc_depo_kayip_count = 0 THEN
                  beski_ekipm_uyeye_at          := TRUE;
                  bhatali_ekipm_inv_deposuna_at := TRUE;
                  beski_ekipm_yts_kayip_depo_at := TRUE;
               --eski ekipman KAYIP deposunda
               ELSIF v_sc_uye_no = 0 AND v_sc_depo_kayip_count > 0 THEN
                  --ve kayip degil
                  IF v_yeni_sc_depo_kayip_count = 0 THEN
                     beski_ekipm_uyeye_at          := TRUE;
                     bhatali_ekipm_inv_deposuna_at := TRUE;
                     beski_ekipm_yts_kayip_depo_at := TRUE;
                  --ve kayip
                  --yeni ekipman üyeye verilir
                  ELSE
                     beski_ekipm_uyeye_at          := FALSE;
                     bhatali_ekipm_inv_deposuna_at := TRUE;
                     beski_ekipm_yts_kayip_depo_at := FALSE;
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  --baska bir ekipman o outlette yok ise
                  --ekipman üyeye verilir
                  --sonra YTS deposuna atilir
                  --yeni ekipman üyeye verilir

                  --eski ekipman baska üyede
                  ----------------------------------
                  IF v_sc_uye_no > 0 AND v_sc_uye_no <> iuye_no THEN
                     --eski ekipman baska üyede ve YTS deposu
                     --eski ekipman baska üyede ve kayip deposu
                     --yeni ekipman üyeye verilir
                     beski_ekipm_uyeye_at          := FALSE;
                     bhatali_ekipm_inv_deposuna_at := FALSE;
                     beski_ekipm_yts_kayip_depo_at := FALSE;
                  END IF;

                  --eski ekipman YTS deposunda ve kayip degil
                  --ya da
                  --eski ekipman YTS deposunda ve kayip
                  IF v_sc_uye_no = 0 AND v_sc_depo_kayip_count = 0 THEN
                     beski_ekipm_uyeye_at          := TRUE;
                     bhatali_ekipm_inv_deposuna_at := FALSE;
                     beski_ekipm_yts_kayip_depo_at := TRUE;
                  --eski ekipman KAYIP deposunda
                  ELSIF v_sc_uye_no = 0 AND v_sc_depo_kayip_count > 0 THEN
                     --ve kayip degil
                     IF v_yeni_sc_depo_kayip_count = 0 THEN
                        beski_ekipm_uyeye_at          := TRUE;
                        bhatali_ekipm_inv_deposuna_at := FALSE;
                        beski_ekipm_yts_kayip_depo_at := TRUE;
                     --ve kayip
                     --yeni ekipman üyeye verilir
                     ELSE
                        beski_ekipm_uyeye_at          := FALSE;
                        bhatali_ekipm_inv_deposuna_at := FALSE;
                        beski_ekipm_yts_kayip_depo_at := FALSE;
                     END IF;
                  END IF;
            END;
         END IF;

         IF TRIM (ioutlet_location) IS NOT NULL THEN
            v_sc_outlet_location := TRIM (ioutlet_location);
         ELSIF TRIM (v_sc_outlet_location) IS NULL AND TRIM (ioutlet_location) IS NULL THEN
            odurum     := 'ÜYE OUTLETI BULUNAMADI.DOGRU OUTLETI SEÇINIZ.';
            oproc_name := 'TELEFON_EKIPMAN_IADE';
            RETURN;
         END IF;

         IF     (TRIM (ioutlet_location) IS NOT NULL)
            AND (TRIM (v_sc_outlet_location) IS NOT NULL)
            AND TRIM (ioutlet_location) <> TRIM (v_sc_outlet_location)
            AND v_sc_uye_no = iuye_no THEN
            odurum     := 'SEÇILEN OUTLET ILE SC EKIPMAN OUTLETLERI FARKLI.';
            oproc_name := 'TELEFON_EKIPMAN_IADE';
            RETURN;
         END IF;

         IF bhatali_ekipm_inv_deposuna_at THEN
            IF iok = '0:E' THEN
               odurum      :=    '1:E ÜYENIN OUTLETINDE BASKA BIR EKIPMAN BULUNMAKTADIR.'
                              || CHR (10)
                              || CHR (13)
                              || 'BU EKIPMANIN INVALID DEPOSUNA ATILMASINI ONAYLIYOR MUSUNUZ?';
               RETURN;
            -- kullanici OK lerse islemi yap
            ELSIF iok = '1:E' OR iok = '2:E' OR iok = '3:E' OR iok = '4:E' OR iok = '5:E' OR iok = '6:E' THEN
               ekipman_pack.ekipman_cikar (iuye_no,
                                           v_hatali_sc_serial_number,
                                           v_sc_outlet_location,
                                           its_no,
                                           its_form_no,
                                           v_reason_code, --YTS TELEFON
                                           'INV', --v_depoya,
                                           v_service_address_id,
                                           igiren_kullanici,
                                           iotorizasyon_no,
                                           ilg_teknik_servis_sifre_id,
                                           in_aciklama,
                                           odurum,
                                           v_taa_uyari,
                                           oproc_name,
                                           ois_emri,
                                           v_error_type,
                                           v_error_code,
                                           v_error_text
                                          );

               IF odurum <> '0' THEN
                  RETURN;
               END IF;

               -- addressability_pack.pin_kodu_sifirlama (v_hatali_sc_serial_number, igiren_kullanici, odurum);
               v_hatali_sc_inv_depo_at := 'E';
            END IF;
         END IF;

         IF yyetki_ekipmani_uyeye_atama > 0 AND beski_ekipm_uyeye_at THEN
            IF iok = '0:E' OR iok = '1:E' THEN
               odurum := '2:E ESKI EKIPMAN ÜYEYE VERILIP TEKRAR BELIRTILEN DEPOYA ATILACAKTIR.' || CHR (10) || CHR (13) || 'BU ISLEMLERI ONAYLIYOR MUSUNUZ?';
               RETURN;
            --kullanici OK lerse islemi yap
            ELSIF iok = '2:E' OR iok = '3:E' OR iok = '4:E' OR iok = '5:E' OR iok = '6:E' THEN
               ekipman_pack.ekipman_ekle (iuye_no,
                                          isc_serial_number,
                                          v_sc_outlet_location,
                                          its_no,
                                          its_form_no,
                                          v_reason_code, --YTS TELEFON
                                          NULL,
                                          v_service_address_id,
                                          'N',
                                          'N',
                                          igiren_kullanici,
                                          iotorizasyon_no,
                                          ilg_teknik_servis_sifre_id,
                                          NULL, --sozlesme_no
                                          in_aciklama,
                                          odurum,
                                          oproc_name,
                                          ois_emri,
                                          v_error_type,
                                          v_error_code,
                                          v_error_text
                                         );

               --   if (odurum = 'BU EKIPMANI BU DEPODAN UYEYE VERME YETKINIZ YOK.' or
               --        odurum = 'YENI KART, KULLANILAMAZ KARTLAR ARASINDA.ÜYEYE VERILEMEZ.' or
               --        odurum = 'YENI KART AKTIF DURUMDA DEGIL.ÜYEYE VERILEMEZ.') then
               IF odurum <> 0 THEN
                  IF iok = '0:E' OR iok = '1:E' OR iok = '2:E' THEN
                     odurum      :=    '3:E ESKI EKIPMAN ÜYEYE VERILEMEDI.'
                                    || CHR (10)
                                    || CHR (13)
                                    || odurum
                                    || CHR (10)
                                    || CHR (13)
                                    || 'DEVAM ETMEK ISTIYOR MUSUNUZ?';
                     RETURN;
                  END IF;

                  IF iok = '3:E' OR iok = '4:E' OR iok = '5:E' OR iok = '6:E' THEN
                     beski_ekipm_uyeye_at := FALSE;
                  ELSE
                     RETURN;
                  END IF;
               END IF;

               v_sc_ekipm_uyeye_atildi := 'E';
            END IF;
         END IF;

         IF    (yyetki_ekipmani_uyeye_atama > 0 AND beski_ekipm_uyeye_at AND beski_ekipm_yts_kayip_depo_at)
            OR (beski_ekipm_yts_kayip_depo_at AND v_sc_uye_no = iuye_no) THEN
            bt_uye_ts_pack.bt_uye_ts_guncel_feed (iuye_no,
                                                  ioutlet_location,
                                                  its_no,
                                                  4, --IN_YTS_ISLEM_TIPI
                                                  'C', --IN_STATUS
                                                  NULL, --IN_MEMO_KOD,
                                                  NULL, --IN_SEBEP_KOD,
                                                  6, --IN_EKRAN_KOD
                                                  igiren_kullanici,
                                                  'VALIDASYON EKIPMAN SÖKÜM',
                                                  odurum
                                                 );

            IF odurum <> '0' THEN
               oproc_name := 'BT_UYE_TS_GUNCEL_FEED';
               RETURN;
            END IF;

            ekipman_pack.ekipman_cikar (iuye_no,
                                        isc_serial_number,
                                        v_sc_outlet_location,
                                        its_no,
                                        its_form_no,
                                        v_reason_code, --YTS TELEFON
                                        isc_depo_kodu,
                                        v_service_address_id,
                                        igiren_kullanici,
                                        iotorizasyon_no,
                                        ilg_teknik_servis_sifre_id,
                                        in_aciklama,
                                        odurum,
                                        v_taa_uyari,
                                        oproc_name,
                                        ois_emri,
                                        v_error_type,
                                        v_error_code,
                                        v_error_text
                                       );

            IF odurum <> '0' THEN
               RETURN;
            END IF;

            -- addressability_pack.pin_kodu_sifirlama (isc_serial_number, igiren_kullanici, odurum);
            v_sc_ekipm_yts_kayip_at := 'E';
         END IF;
      END IF;

      ----------------------------------
      --STB islemleri
      --eski ekipman dogru üyede
      ----------------------------------
      IF TRIM (ioutlet_location) IS NOT NULL THEN
         v_stb_outlet_location := TRIM (ioutlet_location);
      ELSIF TRIM (v_stb_outlet_location) IS NULL AND TRIM (ioutlet_location) IS NULL THEN
         odurum     := 'ÜYE OUTLETI BULUNAMADI.DOGRU OUTLETI SEÇINIZ.';
         oproc_name := 'TELEFON_EKIPMAN_IADE';
         RETURN;
      END IF;

      IF     (TRIM (ioutlet_location) IS NOT NULL)
         AND (TRIM (v_stb_outlet_location) IS NOT NULL)
         AND TRIM (ioutlet_location) <> TRIM (v_stb_outlet_location)
         AND v_stb_uye_no = iuye_no THEN
         odurum     := 'SEÇILEN OUTLET ILE STB EKIPMAN OUTLETLERI FARKLI.';
         oproc_name := 'TELEFON_EKIPMAN_IADE';
         RETURN;
      END IF;

      IF TRIM (istb_serial_number) IS NOT NULL THEN
         IF v_stb_uye_no = iuye_no THEN
            --Eski ekipmanin durumuna göre
            --YTS deposuna atilir
            --KAYIP deposuna atilir
            beski_ekipm_uyeye_at          := FALSE;
            bhatali_ekipm_inv_deposuna_at := FALSE;
            beski_ekipm_yts_kayip_depo_at := TRUE;
         --eski ekipman dogru üyede degil veya depoda
         -----------------------------------------------
         ELSE
            --eski ekipman kayip çalinti deposunda mi?
            IF TRIM (v_stb_equip_location_code) IS NOT NULL AND v_stb_uye_no = 0 THEN
               SELECT COUNT (1)
                 INTO v_stb_depo_kayip_count
                 FROM wiz_equip_location_codes
                WHERE ust_depo_kod = 'KAYIP/CALINTI' AND equip_location_code = v_stb_equip_location_code;
            ELSIF TRIM (v_stb_equip_location_code) IS NOT NULL THEN
               odurum     := 'ÜYE BILGISI VE LOKASYON KODU ELDE EDILEMEDI.';
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            END IF;

            --outlet bilgisi yok ise bul...
            IF TRIM (ioutlet_location) IS NULL THEN
               SELECT COUNT (DISTINCT (outlet_location))
                 INTO v_count
                 FROM wiz_equip
                WHERE account_number = iuye_no;

               IF v_count > 1 THEN
                  odurum     := 'ÜYENIN BIRDEN FAZLA OUTLETI VAR. OUTLET SEÇINIZ.';
                  oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
                  RETURN;
               ELSIF v_count = 0 THEN
                  odurum     := 'ÜYENIN OUTLETI ELDE EDILEMEDI. OUTLET SEÇINIZ.';
                  oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
                  RETURN;
               ELSE
                  --üyenin tek outleti var o kullanilacak
                  --problem yok
                  buyenin_tek_outleti_var := TRUE;
               END IF;
            --outlet bilgisi var ise bulunan ile uyumlu mu?
            ELSIF TRIM (v_stb_outlet_location) IS NOT NULL AND (TRIM (ioutlet_location) <> TRIM (v_stb_outlet_location)) THEN
               odurum     := 'ÜYE OUTLETI ILE EKIPMAN OUTLETI FARKLI.DOGRU OUTLETI SEÇINIZ.';
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            --outlet bilgisi var, ekrandan girilmis ve o kullanilacak ise
            --problem yok o outleti kontrol et
            ELSE
               NULL;
            END IF;
         END IF;

         --varolan tek bir outletten islem yapilabilir durumda
         --isleme devam et
         IF (v_stb_uye_no <> iuye_no) AND (buyenin_tek_outleti_var OR TRIM (ioutlet_location) IS NOT NULL) THEN
            BEGIN
               IF TRIM (ioutlet_location) IS NULL THEN
                  SELECT serial_number, outlet_location
                    INTO v_hatali_stb_serial_number, v_stb_outlet_location
                    FROM wiz_equip
                   WHERE account_number = iuye_no AND converter_type = v_stb_converter_type;
               ELSE
                  SELECT serial_number
                    INTO v_hatali_stb_serial_number
                    FROM wiz_equip
                   WHERE account_number = iuye_no AND outlet_location = TRIM (ioutlet_location) AND converter_type = v_stb_converter_type;
               END IF;

               --baska bir ekipman o outlette var ise
               --üyedeki ekipman INV deposuna atilir
               --beyan edilen ekipman üyeye verilir
               --sonra YTS deposuna atilir
               --yeni ekipman üyeye verilir

               --eski ekipman baska üyede
               ----------------------------------
               IF v_stb_uye_no > 0 AND v_stb_uye_no <> iuye_no THEN
                  --eski ekipman baska üyede ve YTS deposu
                  --eski ekipman baska üyede ve kayip deposu
                  --yeni ekipman üyeye verilir
                  beski_ekipm_uyeye_at          := FALSE;
                  bhatali_ekipm_inv_deposuna_at := TRUE;
                  beski_ekipm_yts_kayip_depo_at := FALSE;
               END IF;

               --eski ekipman YTS deposunda ve kayip degil
               --ya da
               --eski ekipman YTS deposunda ve kayip
               IF v_stb_uye_no = 0 AND v_stb_depo_kayip_count = 0 THEN
                  beski_ekipm_uyeye_at          := TRUE;
                  bhatali_ekipm_inv_deposuna_at := TRUE;
                  beski_ekipm_yts_kayip_depo_at := TRUE;
               --eski ekipman KAYIP deposunda
               ELSIF v_stb_uye_no = 0 AND v_stb_depo_kayip_count > 0 THEN
                  --ve kayip degil
                  IF v_yeni_stb_depo_kayip_count = 0 THEN
                     beski_ekipm_uyeye_at          := TRUE;
                     bhatali_ekipm_inv_deposuna_at := TRUE;
                     beski_ekipm_yts_kayip_depo_at := TRUE;
                  --ve kayip
                  --yeni ekipman üyeye verilir
                  ELSE
                     beski_ekipm_uyeye_at          := FALSE;
                     bhatali_ekipm_inv_deposuna_at := TRUE;
                     beski_ekipm_yts_kayip_depo_at := FALSE;
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  --baska bir ekipman o outlette yok ise
                  --ekipman üyeye verilir
                  --sonra YTS deposuna atilir
                  --yeni ekipman üyeye verilir

                  --eski ekipman baska üyede
                  ----------------------------------
                  IF v_stb_uye_no > 0 AND v_stb_uye_no <> iuye_no THEN
                     --eski ekipman baska üyede ve YTS deposu
                     --eski ekipman baska üyede ve kayip deposu
                     --yeni ekipman üyeye verilir
                     beski_ekipm_uyeye_at          := FALSE;
                     bhatali_ekipm_inv_deposuna_at := FALSE;
                     beski_ekipm_yts_kayip_depo_at := FALSE;
                  END IF;

                  --eski ekipman YTS deposunda ve kayip degil
                  --ya da
                  --eski ekipman YTS deposunda ve kayip
                  IF v_stb_uye_no = 0 AND v_stb_depo_kayip_count = 0 THEN
                     beski_ekipm_uyeye_at          := TRUE;
                     bhatali_ekipm_inv_deposuna_at := FALSE;
                     beski_ekipm_yts_kayip_depo_at := TRUE;
                  --eski ekipman KAYIP deposunda
                  ELSIF v_stb_uye_no = 0 AND v_stb_depo_kayip_count > 0 THEN
                     --ve kayip degil
                     IF v_yeni_stb_depo_kayip_count = 0 THEN
                        beski_ekipm_uyeye_at          := TRUE;
                        bhatali_ekipm_inv_deposuna_at := FALSE;
                        beski_ekipm_yts_kayip_depo_at := TRUE;
                     --ve kayip
                     --yeni ekipman üyeye verilir
                     ELSE
                        beski_ekipm_uyeye_at          := FALSE;
                        bhatali_ekipm_inv_deposuna_at := FALSE;
                        beski_ekipm_yts_kayip_depo_at := FALSE;
                     END IF;
                  END IF;
            END;
         END IF;

         IF bhatali_ekipm_inv_deposuna_at THEN
            IF iok = '0:E' OR iok = '1:E' OR iok = '2:E' OR iok = '3:E' THEN
               odurum      :=    '4:E ÜYENIN OUTLETINDE BASKA BIR EKIPMAN BULUNMAKTADIR.'
                              || CHR (10)
                              || CHR (13)
                              || 'BU EKIPMANIN INVALID DEPOSUNA ATILMASINI ONAYLIYOR MUSUNUZ?';
               RETURN;
            --kullanici OK lerse islemi yap
            ELSIF iok = '4:E' OR iok = '5:E' OR iok = '6:E' THEN
               ekipman_pack.ekipman_cikar (iuye_no,
                                           v_hatali_stb_serial_number,
                                           v_stb_outlet_location,
                                           its_no,
                                           its_form_no,
                                           v_reason_code, --YTS TELEFON
                                           'INV', --v_depoya,
                                           v_service_address_id,
                                           igiren_kullanici,
                                           iotorizasyon_no,
                                           ilg_teknik_servis_sifre_id,
                                           in_aciklama,
                                           odurum,
                                           v_taa_uyari,
                                           oproc_name,
                                           ois_emri,
                                           v_error_type,
                                           v_error_code,
                                           v_error_text
                                          );

               IF odurum <> '0' THEN
                  RETURN;
               END IF;

               v_hatali_stb_inv_depo_at := 'E';
            END IF;
         END IF;

         IF yyetki_ekipmani_uyeye_atama > 0 AND beski_ekipm_uyeye_at THEN
            IF iok = '0:E' OR iok = '1:E' OR iok = '2:E' OR iok = '3:E' OR iok = '4:E' THEN
               odurum := '5:E ESKI EKIPMAN ÜYEYE VERILIP TEKRAR BELIRTILEN DEPOYA ATILACAKTIR.' || CHR (10) || CHR (13) || 'BU ISLEMLERI ONAYLIYOR MUSUNUZ?';
               RETURN;
            --kullanici OK lerse islemi yap
            ELSIF iok = '5:E' OR iok = '6:E' THEN
               ekipman_pack.ekipman_ekle (iuye_no,
                                          istb_serial_number,
                                          v_stb_outlet_location,
                                          its_no,
                                          its_form_no,
                                          v_reason_code, --YTS TELEFON
                                          NULL,
                                          v_service_address_id,
                                          'N',
                                          'N',
                                          igiren_kullanici,
                                          iotorizasyon_no,
                                          ilg_teknik_servis_sifre_id,
                                          NULL, --sozlesme_no
                                          in_aciklama,
                                          odurum,
                                          oproc_name,
                                          ois_emri,
                                          v_error_type,
                                          v_error_code,
                                          v_error_text
                                         );

               --   if (odurum = 'BU EKIPMANI BU DEPODAN UYEYE VERME YETKINIZ YOK.' or
               --        odurum = 'YENI KART, KULLANILAMAZ KARTLAR ARASINDA.ÜYEYE VERILEMEZ.' or
               --        odurum = 'YENI KART AKTIF DURUMDA DEGIL.ÜYEYE VERILEMEZ.') then
               IF odurum <> 0 THEN
                  IF iok = '0:E' OR iok = '1:E' OR iok = '2:E' OR iok = '3:E' OR iok = '4:E' OR iok = '5:E' THEN
                     odurum      :=    '6:E ESKI EKIPMAN ÜYEYE VERILEMEDI.'
                                    || CHR (10)
                                    || CHR (13)
                                    || odurum
                                    || CHR (10)
                                    || CHR (13)
                                    || 'DEVAM ETMEK ISTIYOR MUSUNUZ?';
                     RETURN;
                  END IF;

                  IF iok = '6:E' THEN
                     beski_ekipm_uyeye_at := FALSE;
                  ELSE
                     RETURN;
                  END IF;
               END IF;

               v_stb_ekipm_uyeye_atildi := 'E';
            END IF;
         END IF;

         IF    (yyetki_ekipmani_uyeye_atama > 0 AND beski_ekipm_uyeye_at AND beski_ekipm_yts_kayip_depo_at)
            OR (beski_ekipm_yts_kayip_depo_at AND v_stb_uye_no = iuye_no) THEN
            bt_uye_ts_pack.bt_uye_ts_guncel_feed (iuye_no,
                                                  ioutlet_location,
                                                  its_no,
                                                  4, --IN_YTS_ISLEM_TIPI
                                                  'C', --IN_STATUS
                                                  NULL, --IN_MEMO_KOD,
                                                  NULL, --IN_SEBEP_KOD,
                                                  6, --IN_EKRAN_KOD
                                                  igiren_kullanici,
                                                  'VALIDASYON EKIPMAN SÖKÜM',
                                                  odurum
                                                 );

            IF odurum <> '0' THEN
               oproc_name := 'BT_UYE_TS_GUNCEL_FEED';
               RETURN;
            END IF;

            ekipman_pack.ekipman_cikar (iuye_no,
                                        istb_serial_number,
                                        v_stb_outlet_location,
                                        its_no,
                                        its_form_no,
                                        v_reason_code, --YTS TELEFON
                                        istb_depo_kodu,
                                        v_service_address_id,
                                        igiren_kullanici,
                                        iotorizasyon_no,
                                        ilg_teknik_servis_sifre_id,
                                        in_aciklama,
                                        odurum,
                                        v_taa_uyari,
                                        oproc_name,
                                        ois_emri,
                                        v_error_type,
                                        v_error_code,
                                        v_error_text
                                       );

            IF odurum <> '0' THEN
               RETURN;
            END IF;

            v_stb_ekipm_yts_kayip_at := 'E';
         END IF;
      END IF;

      --MODUL islemleri   Falamur 06.05.2011
      --eski ekipman dogru üyede
      ----------------------------------
      IF TRIM (ioutlet_location) IS NOT NULL THEN
         v_md_outlet_location := TRIM (ioutlet_location);
      ELSIF TRIM (v_md_outlet_location) IS NULL AND TRIM (ioutlet_location) IS NULL THEN
         odurum     := 'ÜYE OUTLETI BULUNAMADI.DOGRU OUTLETI SEÇINIZ.';
         oproc_name := 'TELEFON_EKIPMAN_IADE';
         RETURN;
      END IF;

      IF     (TRIM (ioutlet_location) IS NOT NULL)
         AND (TRIM (v_md_outlet_location) IS NOT NULL)
         AND TRIM (ioutlet_location) <> TRIM (v_md_outlet_location)
         AND v_md_uye_no = iuye_no THEN
         odurum     := 'SEÇILEN OUTLET ILE MODUL EKIPMAN OUTLETLERI FARKLI.';
         oproc_name := 'TELEFON_EKIPMAN_IADE';
         RETURN;
      END IF;

      IF TRIM (imd_serial_number) IS NOT NULL THEN
         IF v_md_uye_no = iuye_no THEN
            --Eski ekipmanin durumuna göre
            --YTS deposuna atilir
            --KAYIP deposuna atilir
            beski_ekipm_uyeye_at          := FALSE;
            bhatali_ekipm_inv_deposuna_at := FALSE;
            beski_ekipm_yts_kayip_depo_at := TRUE;
         --eski ekipman dogru üyede degil veya depoda
         -----------------------------------------------
         ELSE
            --eski ekipman kayip çalinti deposunda mi?
            IF TRIM (v_md_equip_location_code) IS NOT NULL AND v_md_uye_no = 0 THEN
               SELECT COUNT (1)
                 INTO v_md_depo_kayip_count
                 FROM wiz_equip_location_codes
                WHERE ust_depo_kod = 'KAYIP/CALINTI' AND equip_location_code = v_md_equip_location_code;
            ELSIF TRIM (v_md_equip_location_code) IS NOT NULL THEN
               odurum     := 'ÜYE BILGISI VE LOKASYON KODU ELDE EDILEMEDI.';
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            END IF;

            --outlet bilgisi yok ise bul...
            IF TRIM (ioutlet_location) IS NULL THEN
               SELECT COUNT (DISTINCT (outlet_location))
                 INTO v_count
                 FROM eq_ekipman
                WHERE account_number = iuye_no;

               IF v_count > 1 THEN
                  odurum     := 'ÜYENIN BIRDEN FAZLA OUTLETI VAR. OUTLET SEÇINIZ.';
                  oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
                  RETURN;
               ELSIF v_count = 0 THEN
                  odurum     := 'ÜYENIN OUTLETI ELDE EDILEMEDI. OUTLET SEÇINIZ.';
                  oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
                  RETURN;
               ELSE
                  --üyenin tek outleti var o kullanilacak
                  --problem yok
                  buyenin_tek_outleti_var := TRUE;
               END IF;
            --outlet bilgisi var ise bulunan ile uyumlu mu?
            ELSIF TRIM (v_md_outlet_location) IS NOT NULL AND (TRIM (ioutlet_location) <> TRIM (v_md_outlet_location)) THEN
               odurum     := 'ÜYE OUTLETI ILE EKIPMAN OUTLETI FARKLI.DOGRU OUTLETI SEÇINIZ.';
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            --outlet bilgisi var, ekrandan girilmis ve o kullanilacak ise
            --problem yok o outleti kontrol et
            ELSE
               NULL;
            END IF;
         END IF;

         --varolan tek bir outletten islem yapilabilir durumda
         --isleme devam et
         IF (v_md_uye_no <> iuye_no) AND (buyenin_tek_outleti_var OR TRIM (ioutlet_location) IS NOT NULL) THEN
            BEGIN
               IF TRIM (ioutlet_location) IS NULL THEN
                  SELECT serial_number, outlet_location
                    INTO v_hatali_md_serial_number, v_md_outlet_location
                    FROM eq_ekipman
                   WHERE account_number = iuye_no AND ekipman_tipi = v_md_converter_type;
               ELSE
                  SELECT serial_number
                    INTO v_hatali_md_serial_number
                    FROM eq_ekipman
                   WHERE account_number = iuye_no AND outlet_location = TRIM (ioutlet_location) AND ekipman_tipi = v_md_converter_type;
               END IF;

               --baska bir ekipman o outlette var ise
               --üyedeki ekipman INV deposuna atilir
               --beyan edilen ekipman üyeye verilir
               --sonra YTS deposuna atilir
               --yeni ekipman üyeye verilir

               --eski ekipman baska üyede
               ----------------------------------
               IF v_md_uye_no > 0 AND v_md_uye_no <> iuye_no THEN
                  --eski ekipman baska üyede ve YTS deposu
                  --eski ekipman baska üyede ve kayip deposu
                  --yeni ekipman üyeye verilir
                  beski_ekipm_uyeye_at          := FALSE;
                  bhatali_ekipm_inv_deposuna_at := TRUE;
                  beski_ekipm_yts_kayip_depo_at := FALSE;
               END IF;

               --eski ekipman YTS deposunda ve kayip degil
               --ya da
               --eski ekipman YTS deposunda ve kayip
               IF v_md_uye_no = 0 AND v_md_depo_kayip_count = 0 THEN
                  beski_ekipm_uyeye_at          := TRUE;
                  bhatali_ekipm_inv_deposuna_at := TRUE;
                  beski_ekipm_yts_kayip_depo_at := TRUE;
               --eski ekipman KAYIP deposunda
               ELSIF v_md_uye_no = 0 AND v_md_depo_kayip_count > 0 THEN
                  --ve kayip degil
                  IF v_yeni_md_depo_kayip_count = 0 THEN
                     beski_ekipm_uyeye_at          := TRUE;
                     bhatali_ekipm_inv_deposuna_at := TRUE;
                     beski_ekipm_yts_kayip_depo_at := TRUE;
                  --ve kayip
                  --yeni ekipman üyeye verilir
                  ELSE
                     beski_ekipm_uyeye_at          := FALSE;
                     bhatali_ekipm_inv_deposuna_at := TRUE;
                     beski_ekipm_yts_kayip_depo_at := FALSE;
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  --baska bir ekipman o outlette yok ise
                  --ekipman üyeye verilir
                  --sonra YTS deposuna atilir
                  --yeni ekipman üyeye verilir

                  --eski ekipman baska üyede
                  ----------------------------------
                  IF v_md_uye_no > 0 AND v_md_uye_no <> iuye_no THEN
                     --eski ekipman baska üyede ve YTS deposu
                     --eski ekipman baska üyede ve kayip deposu
                     --yeni ekipman üyeye verilir
                     beski_ekipm_uyeye_at          := FALSE;
                     bhatali_ekipm_inv_deposuna_at := FALSE;
                     beski_ekipm_yts_kayip_depo_at := FALSE;
                  END IF;

                  --eski ekipman YTS deposunda ve kayip degil
                  --ya da
                  --eski ekipman YTS deposunda ve kayip
                  IF v_md_uye_no = 0 AND v_md_depo_kayip_count = 0 THEN
                     beski_ekipm_uyeye_at          := TRUE;
                     bhatali_ekipm_inv_deposuna_at := FALSE;
                     beski_ekipm_yts_kayip_depo_at := TRUE;
                  --eski ekipman KAYIP deposunda
                  ELSIF v_md_uye_no = 0 AND v_md_depo_kayip_count > 0 THEN
                     --ve kayip degil
                     IF v_yeni_md_depo_kayip_count = 0 THEN
                        beski_ekipm_uyeye_at          := TRUE;
                        bhatali_ekipm_inv_deposuna_at := FALSE;
                        beski_ekipm_yts_kayip_depo_at := TRUE;
                     --ve kayip
                     --yeni ekipman üyeye verilir
                     ELSE
                        beski_ekipm_uyeye_at          := FALSE;
                        bhatali_ekipm_inv_deposuna_at := FALSE;
                        beski_ekipm_yts_kayip_depo_at := FALSE;
                     END IF;
                  END IF;
            END;
         END IF;

         IF bhatali_ekipm_inv_deposuna_at THEN
            IF iok = '0:E' OR iok = '1:E' OR iok = '2:E' OR iok = '3:E' THEN
               odurum      :=    '4:E ÜYENIN OUTLETINDE BASKA BIR EKIPMAN BULUNMAKTADIR.'
                              || CHR (10)
                              || CHR (13)
                              || 'BU EKIPMANIN INVALID DEPOSUNA ATILMASINI ONAYLIYOR MUSUNUZ?';
               RETURN;
            --kullanici OK lerse islemi yap
            ELSIF iok = '4:E' OR iok = '5:E' OR iok = '6:E' THEN
               eq_ekipman_pack.eq_ekipman_cikar (iuye_no,
                                                 'INV', --> i_equip_location_code   IN       CHAR,
                                                 v_reason_code,
                                                 v_md_outlet_location,
                                                 248, --> i_ekipman_tipi
                                                 v_hatali_md_serial_number,
                                                 its_no,
                                                 in_aciklama,
                                                 igiren_kullanici,
                                                 SYSDATE,
                                                 ilg_teknik_servis_sifre_id,
                                                 iotorizasyon_no,
                                                 its_form_no,
                                                 odurum,
                                                 v_taa_uyari
                                                );

               IF odurum <> '0' THEN
                  RETURN;
               END IF;

               v_hatali_md_inv_depo_at := 'E';
            END IF;
         END IF;

         IF yyetki_ekipmani_uyeye_atama > 0 AND beski_ekipm_uyeye_at THEN
            IF iok = '0:E' OR iok = '1:E' OR iok = '2:E' OR iok = '3:E' OR iok = '4:E' THEN
               odurum := '5:E ESKI EKIPMAN ÜYEYE VERILIP TEKRAR BELIRTILEN DEPOYA ATILACAKTIR.' || CHR (10) || CHR (13) || 'BU ISLEMLERI ONAYLIYOR MUSUNUZ?';
               RETURN;
            --kullanici OK lerse islemi yap
            ELSIF iok = '5:E' OR iok = '6:E' THEN
               SELECT TRIM (ekipman_modul_tipi)
                 INTO vekipman_modul_tipi
                 FROM eq_ekipman
                WHERE serial_number = imd_serial_number;

               IF vekipman_modul_tipi <> '302' THEN
                  eq_ekipman_pack.eq_ekipman_ekle (iuye_no,
                                                   v_reason_code,
                                                   v_md_outlet_location,
                                                   248, --> i_ekipman_tipi          IN       NUMBER,
                                                   NULL,
                                                   vekipman_modul_tipi,
                                                   imd_serial_number,
                                                   its_no, --> i_sales_agent_code      IN       VARCHAR2,
                                                   SYSDATE, --> i_kurulum_tarihi         IN       DATE,
                                                   in_aciklama, --> i_aciklama              IN       VARCHAR2,
                                                   igiren_kullanici, --> i_kisi                  IN       VARCHAR2,
                                                   SYSDATE, --> i_islem_tarihi          IN       DATE,
                                                   'H', --> i_kontratsiz_aktifleme   IN       VARCHAR2,
                                                   'H', --> i_otel_mi                IN       VARCHAR2,
                                                   NULL, --> i_sozlesme               IN       VARCHAR2,
                                                   ilg_teknik_servis_sifre_id, --> i_ts_sifre_id           IN       NUMBER,
                                                   iotorizasyon_no, --> i_its_kayit_no          IN       VARCHAR2,
                                                   its_form_no, --> i_ts_form_no            IN       VARCHAR2,
                                                   oeq_ekipman_id, --> o_id                     OUT      NUMBER,
                                                   odurum --> o_durum                 OUT      VARCHAR2,
                                                  );
               ELSE
                  eq_ekipman_pack.eq_ekipman_ekle (iuye_no,
                                                   v_reason_code,
                                                   v_md_outlet_location,
                                                   302, --> i_ekipman_tipi          IN       NUMBER,
                                                   NULL,
                                                   vekipman_modul_tipi,
                                                   imd_serial_number,
                                                   its_no, --> i_sales_agent_code      IN       VARCHAR2,
                                                   SYSDATE, --> i_kurulum_tarihi         IN       DATE,
                                                   in_aciklama, --> i_aciklama              IN       VARCHAR2,
                                                   igiren_kullanici, --> i_kisi                  IN       VARCHAR2,
                                                   SYSDATE, --> i_islem_tarihi          IN       DATE,
                                                   'H', --> i_kontratsiz_aktifleme   IN       VARCHAR2,
                                                   'H', --> i_otel_mi                IN       VARCHAR2,
                                                   NULL, --> i_sozlesme               IN       VARCHAR2,
                                                   ilg_teknik_servis_sifre_id, --> i_ts_sifre_id           IN       NUMBER,
                                                   iotorizasyon_no, --> i_its_kayit_no          IN       VARCHAR2,
                                                   its_form_no, --> i_ts_form_no            IN       VARCHAR2,
                                                   oeq_ekipman_id, --> o_id                     OUT      NUMBER,
                                                   odurum --> o_durum                 OUT      VARCHAR2,
                                                  );
               END IF;

               --   if (odurum = 'BU EKIPMANI BU DEPODAN UYEYE VERME YETKINIZ YOK.' or
               --        odurum = 'YENI KART, KULLANILAMAZ KARTLAR ARASINDA.ÜYEYE VERILEMEZ.' or
               --        odurum = 'YENI KART AKTIF DURUMDA DEGIL.ÜYEYE VERILEMEZ.') then
               IF odurum <> 0 THEN
                  IF iok = '0:E' OR iok = '1:E' OR iok = '2:E' OR iok = '3:E' OR iok = '4:E' OR iok = '5:E' THEN
                     odurum      :=    '6:E ESKI EKIPMAN ÜYEYE VERILEMEDI.'
                                    || CHR (10)
                                    || CHR (13)
                                    || odurum
                                    || CHR (10)
                                    || CHR (13)
                                    || 'DEVAM ETMEK ISTIYOR MUSUNUZ?';
                     RETURN;
                  END IF;

                  IF iok = '6:E' THEN
                     beski_ekipm_uyeye_at := FALSE;
                  ELSE
                     RETURN;
                  END IF;
               END IF;

               v_md_ekipm_uyeye_atildi := 'E';
            END IF;
         END IF;

         IF    (yyetki_ekipmani_uyeye_atama > 0 AND beski_ekipm_uyeye_at AND beski_ekipm_yts_kayip_depo_at)
            OR (beski_ekipm_yts_kayip_depo_at AND v_md_uye_no = iuye_no) THEN
            bt_uye_ts_pack.bt_uye_ts_guncel_feed (iuye_no,
                                                  ioutlet_location,
                                                  its_no,
                                                  4, --IN_YTS_ISLEM_TIPI
                                                  'C', --IN_STATUS
                                                  NULL, --IN_MEMO_KOD,
                                                  NULL, --IN_SEBEP_KOD,
                                                  6, --IN_EKRAN_KOD
                                                  igiren_kullanici,
                                                  'VALIDASYON EKIPMAN SÖKÜM',
                                                  odurum
                                                 );

            IF odurum <> '0' THEN
               oproc_name := 'BT_UYE_TS_GUNCEL_FEED';
               RETURN;
            END IF;

            --ekipman iade de 302 eklendi
            IF v_md_converter_type <> '302' THEN
               eq_ekipman_pack.eq_ekipman_cikar (iuye_no,
                                                 imd_depo_kodu,
                                                 v_reason_code,
                                                 v_md_outlet_location,
                                                 248, --> i_ekipman_tipi
                                                 imd_serial_number,
                                                 its_no,
                                                 in_aciklama,
                                                 igiren_kullanici,
                                                 SYSDATE,
                                                 ilg_teknik_servis_sifre_id,
                                                 iotorizasyon_no,
                                                 its_form_no,
                                                 odurum,
                                                 v_taa_uyari
                                                );
            ELSE
               eq_ekipman_pack.eq_ekipman_cikar (iuye_no,
                                                 imd_depo_kodu,
                                                 v_reason_code,
                                                 v_md_outlet_location,
                                                 302, --> i_ekipman_tipi
                                                 imd_serial_number,
                                                 its_no,
                                                 in_aciklama,
                                                 igiren_kullanici,
                                                 SYSDATE,
                                                 ilg_teknik_servis_sifre_id,
                                                 iotorizasyon_no,
                                                 its_form_no,
                                                 odurum,
                                                 v_taa_uyari
                                                );
            END IF;

            IF odurum <> '0' THEN
               RETURN;
            END IF;

            v_md_ekipm_yts_kayip_at := 'E';
         END IF;
      END IF;

      --Hersey OK ise islemleri yap
      IF v_iris_kullanici = 0 THEN
         UPDATE lg_teknik_servis_sifre
            SET ts_form_no = its_form_no
          WHERE id = ilg_teknik_servis_sifre_id AND ts_form_no IS NULL;
      END IF;

      IF TRIM (v_sc_outlet_location) IS NULL AND TRIM (v_stb_outlet_location) IS NULL AND TRIM (ioutlet_location) IS NULL THEN
         odurum     := 'ÜYE OUTLETI BULUNAMADI.DOGRU OUTLETI SEÇINIZ.';
         oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
         RETURN;
      ELSIF     TRIM (ioutlet_location) IS NOT NULL
            AND TRIM (v_sc_outlet_location) IS NOT NULL
            AND TRIM (ioutlet_location) <> TRIM (v_sc_outlet_location)
            AND TRIM (iuye_no) = TRIM (v_sc_uye_no) THEN
         odurum     := 'SEÇILEN OUTLET ILE EKIPMAN OUTLETLERI FARKLI.';
         oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
         RETURN;
      END IF;

      IF     TRIM (ioutlet_location) IS NOT NULL
         AND TRIM (v_stb_outlet_location) IS NOT NULL
         AND TRIM (ioutlet_location) <> TRIM (v_stb_outlet_location)
         AND TRIM (iuye_no) = TRIM (v_stb_uye_no) THEN
         odurum     := 'SEÇILEN OUTLET ILE EKIPMAN OUTLETLERI FARKLI.';
         oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
         RETURN;
      END IF;

      IF TRIM (ioutlet_location) IS NOT NULL THEN
         v_sc_outlet_location  := TRIM (ioutlet_location);
         v_stb_outlet_location := TRIM (ioutlet_location);
      ELSIF TRIM (v_stb_outlet_location) IS NOT NULL AND TRIM (v_sc_outlet_location) IS NULL THEN
         v_sc_outlet_location := v_stb_outlet_location;
      END IF;

      IF v_iris_kullanici = 0 THEN
         ekipman_pack.lg_telefon_ekipm_islem_ins_upd (2,
                                                      NULL,
                                                      iotorizasyon_no,
                                                      ilg_teknik_servis_sifre_id,
                                                      its_no,
                                                      v_sc_equip_location_code,
                                                      v_stb_equip_location_code,
                                                      v_md_equip_location_code,
                                                      iuye_no,
                                                      v_sc_outlet_location,
                                                      isc_serial_number,
                                                      istb_serial_number,
                                                      imd_serial_number,
                                                      NULL,
                                                      NULL,
                                                      NULL,
                                                      v_hatali_sc_serial_number,
                                                      v_hatali_stb_serial_number,
                                                      v_hatali_md_serial_number,
                                                      isc_kayip,
                                                      istb_kayip,
                                                      imd_kayip,
                                                      its_form_no,
                                                      in_aciklama,
                                                      v_sc_ekipm_uyeye_atildi,
                                                      v_hatali_sc_inv_depo_at,
                                                      v_sc_ekipm_yts_kayip_at,
                                                      v_stb_ekipm_uyeye_atildi,
                                                      v_hatali_stb_inv_depo_at,
                                                      v_stb_ekipm_yts_kayip_at,
                                                      v_md_ekipm_uyeye_atildi,
                                                      v_hatali_md_inv_depo_at,
                                                      v_md_ekipm_yts_kayip_at,
                                                      igiren_kullanici,
                                                      odurum
                                                     );

         IF odurum <> '0' THEN
            RETURN;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         odurum     := SQLERRM;
         oproc_name := 'TELEFON_EKIPMAN_IADE';
         RETURN;
   END;

   PROCEDURE telefon_ekipman_degisim (ialt_islem_tipi            IN     VARCHAR2,
                                      iotorizasyon_no            IN     its_servis.kayit_no%TYPE,
                                      ilg_teknik_servis_sifre_id IN     lg_teknik_servis_sifre.id%TYPE,
                                      its_no                     IN     lg_ekipman.sales_agent_code%TYPE,
                                      idepo_kodu                 IN     lg_ekipman.depoya%TYPE,
                                      iuye_no                    IN     wiz_equip.account_number%TYPE,
                                      ioutlet_location           IN     wiz_equip.outlet_location%TYPE,
                                      iold_serial_number         IN     wiz_equip.serial_number%TYPE,
                                      inew_serial_number         IN     wiz_equip.serial_number%TYPE,
                                      iekipman_kayip             IN     CHAR,
                                      its_form_no                IN     lg_ekipman.ts_form_no%TYPE,
                                      in_aciklama                IN     lg_ekipman.aciklama%TYPE,
                                      igiren_kullanici           IN     co_kullanici.kod%TYPE,
                                      iok                        IN     VARCHAR2 := '0:E',
                                      odurum                        OUT VARCHAR2,
                                      oproc_name                    OUT VARCHAR2
                                     ) IS
      v_new_equip_location_code     wiz_equip.equip_location_code%TYPE;
      v_old_equip_location_code     wiz_equip.equip_location_code%TYPE;
      v_new_converter_type          VARCHAR2 (3); --wiz_equip.converter_type%TYPE;
      v_old_converter_type          VARCHAR2 (3); --wiz_equip.converter_type%TYPE;
      v_new_depo_kayip_count        NUMBER := 0;
      v_old_depo_kayip_count        NUMBER := 0;
      v_new_account_number          wiz_equip.account_number%TYPE;
      v_old_account_number          wiz_equip.account_number%TYPE;
      v_hatali_serial_number        wiz_equip.serial_number%TYPE;
      v_count                       NUMBER := 0;
      v_outlet_location             wiz_equip.outlet_location%TYPE;
      v_service_address_id          wiz_customer_hp_life.service_address_id%TYPE;
      v_franchise_code              wiz_customer_hp_life.franchise_code%TYPE;
      v_stb_tipi                    wiz_customer_hp_life.hp_cluster%TYPE;
      ois_emri                      NUMBER (10); --wiz_work_order.work_order_number%TYPE;
      beski_ekipm_uyeye_at          BOOLEAN := FALSE;
      bhatali_ekipm_inv_deposuna_at BOOLEAN := FALSE;
      beski_ekipm_yts_kayip_depo_at BOOLEAN := FALSE;
      buyenin_tek_outleti_var       BOOLEAN := FALSE;
      v_eski_ekipm_uyeye_atildi     CHAR (1) := 'H';
      v_hatali_ekipm_inv_depo_at    CHAR (1) := 'H';
      v_eski_ekipm_yts_kayip_at     CHAR (1) := 'H';
      yyetki_ekipmani_uyeye_atama   NUMBER := 0;
      v_yeni_depo_kayip_count       NUMBER := 0;
      v_eski_depo_kayip_count       NUMBER := 0;
      v_error_type                  NUMBER (1);
      v_error_code                  VARCHAR2 (10);
      v_error_text                  VARCHAR2 (512);
      v_iris_kullanici              NUMBER := 0;
      v_reason_code                 lg_ekipman.depoya%TYPE := 'YTL';
      v_taa_uyari                   VARCHAR2 (512);
      v_new_ekipman_tip_matrix_id   eq_ekipman_tip_matrix.eq_ekipman_tip_matrix_id%TYPE;
      v_old_ekipman_tip_matrix_id   eq_ekipman_tip_matrix.eq_ekipman_tip_matrix_id%TYPE;
      v_old_hd_destekli             CHAR (1);
      v_new_hd_destekli             CHAR (1);
      oerror_type                   NUMBER;
      oerror_code                   VARCHAR2 (500);
      oerror_text                   VARCHAR2 (500);
      out_result                    VARCHAR2 (1);
      vekipman_tipi                 NUMBER;
      vekipman_modul_tipi           NUMBER;
      oeq_ekipman_id                NUMBER;
      v_memo_count                  NUMBER;
   --iOK = '0:E' hersey ok default
   --iOK = '1:E' 'ÜYENIN OUTLETINDE BASKA BIR EKIPMAN BULUNMAKTADIR.'||CHR(10)||CHR(13)||'BU EKIPMANIN INVALID DEPOSUNA ATILMASINI ONAYLIYOR MUSUNUZ?';
   --iOK = '2:E' 'ESKI EKIPMAN ÜYEYE VERILIP TEKRAR BELIRTILEN DEPOYA ATILACAKTIR.'||CHR(10)||CHR(13)||'BU ISLEMLERI ONAYLIYOR MUSUNUZ?';
   --iOK = '3:E' ekipman eklemede hata olustu devam edilsin mi
   --ESKI EKIPMAN ÜYEYE VERILEMEDI.'||CHR(10)||CHR(13)||odurum||CHR(10)||CHR(13)||'DEVAM ETMEK ISTIYOR MUSUNUZ?';
   BEGIN
      odurum                      := 'FAILED';
      oproc_name                  := 'TELEFON_EKIPMAN_DEGISIM';

      IF igiren_kullanici IN ('SYSIRIS', 'SYSIVR') THEN
         v_iris_kullanici := 1;
         v_reason_code    := 'INT';
      END IF;

      v_outlet_location           := TRIM (ioutlet_location);
      yyetki_ekipmani_uyeye_atama := yetki_pack.yetkisi_varmi (igiren_kullanici, 'ISLEM_EKIPMANI_DUZELTME_ICIN_UYEYE_ATAMA');

      BEGIN
         SELECT service_address_id, franchise_code, hp_cluster
           INTO v_service_address_id, v_franchise_code, v_stb_tipi
           FROM wiz_customer_hp_life
          WHERE account_number = iuye_no;
      EXCEPTION
         WHEN OTHERS THEN
            odurum     := 'ÜYE KAYDI BULUNAMADI.';
            oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
            RETURN;
      END;

      -------------------------------------------------------
      --eski ekipman islemleri
      -------------------------------------------------------
      BEGIN
         SELECT outlet_location, converter_type, equip_location_code, account_number
           INTO v_outlet_location, v_old_converter_type, v_old_equip_location_code, v_old_account_number
           FROM wiz_equip
          WHERE serial_number = iold_serial_number;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT outlet_location, ekipman_tipi, equip_location_code, account_number
                 INTO v_outlet_location, v_old_converter_type, v_old_equip_location_code, v_old_account_number
                 FROM eq_ekipman
                WHERE serial_number = iold_serial_number;
            EXCEPTION
               WHEN OTHERS THEN
                  odurum     := 'ESKI EKIPMAN SISTEMDE KAYITLI DEGIL.';
                  oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
                  RETURN;
            END;
         WHEN OTHERS THEN
            odurum     := 'ESKI EKIPMAN SISTEMDE KAYITLI DEGIL.';
            oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
            RETURN;
      END;

      -------------------------------------------------------
      --yeni ekipman islemleri
      -------------------------------------------------------
      BEGIN
         SELECT converter_type, equip_location_code, account_number
           INTO v_new_converter_type, v_new_equip_location_code, v_new_account_number
           FROM wiz_equip
          WHERE serial_number = inew_serial_number;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT ekipman_tipi, equip_location_code, account_number
                 INTO v_new_converter_type, v_new_equip_location_code, v_new_account_number
                 FROM eq_ekipman
                WHERE serial_number = inew_serial_number;
            EXCEPTION
               WHEN OTHERS THEN
                  odurum     := 'YENI EKIPMAN SISTEMDE KAYITLI DEGIL.';
                  oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
                  RETURN;
            END;
         WHEN OTHERS THEN
            odurum     := 'YENI EKIPMAN SISTEMDE KAYITLI DEGIL.';
            oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
            RETURN;
      END;

      IF v_new_converter_type = 'ST' THEN
         vekipman_tipi := 247;
      ELSIF v_new_converter_type = 'SC' THEN
         vekipman_tipi := 246;
      ELSIF v_new_converter_type = '248' THEN
         vekipman_tipi := 248;
      ELSIF v_new_converter_type = '300' THEN
         vekipman_tipi := 300;
      ELSIF v_new_converter_type = '301' THEN
         vekipman_tipi := 301;
      ELSIF v_new_converter_type = '302' THEN
         vekipman_tipi := 302;
      END IF;

      IF v_new_converter_type = '248' OR v_new_converter_type = '300' OR v_new_converter_type = '301' OR v_new_converter_type = '302' THEN
         SELECT TRIM (ekipman_modul_tipi)
           INTO vekipman_modul_tipi
           FROM eq_ekipman
          WHERE serial_number = inew_serial_number;
      END IF;

      /*  01 : Falamur Eski ekipman var ise o zaman aşağıda ki kontrol etmesi gerekiyor.*/
      IF ialt_islem_tipi = 'STB_DEGISIM' THEN
         IF dbs_sabit ('HOS_PAKET_KUTU_DEG_GECERLI') = 'E' THEN
            DECLARE
               v_taahhut_bitis_tarih DATE;
            BEGIN
               -- EKayan, 12285, Hos paket üyesinin taahütü bittiyse garantisi bitmistir, degisime izin verilmez.
               -- Aslinda satilmis kutularin garanti süresi takibi ile bu is yapilmali ancak yapi izin vermiyor.
               v_taahhut_bitis_tarih := hos_paket_uyesi_mi (iuye_no, ioutlet_location, 'E');

               IF v_taahhut_bitis_tarih IS NOT NULL AND v_taahhut_bitis_tarih < SYSDATE THEN
                  odurum     := 'Kutu garanti süresi doldugu için degisim yapilamaz.';
                  oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
                  RETURN;
               END IF;
            END;
         END IF;
      END IF;

      /*  02 : Falamur yeni ekipman var ise o zaman aşağıda ki kontrol etmesi gerekiyor.*/
      --yeni depo kayip deposu mu yoksa YTS deposu mu
      SELECT COUNT (1)
        INTO v_yeni_depo_kayip_count
        FROM wiz_equip_location_codes
       WHERE ust_depo_kod = dbs_sabit ('EKIPMAN_LOKASYON_KAYIP_CALINTI') AND equip_location_code = idepo_kodu;

      IF iekipman_kayip = 'H' THEN
         IF v_yeni_depo_kayip_count > 0 THEN
            odurum     := 'EKIPMAN KAYIP OLARAK ISARETLENMEMIS FAKAT DEPO KODU KAYIP ÇALINTI SEÇILMIS.';
            oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
            RETURN;
         END IF;
      ELSIF iekipman_kayip = 'E' THEN
         IF v_yeni_depo_kayip_count = 0 AND yetki_pack.yetkisi_varmi (igiren_kullanici, 'ISLEM_KAYIPTAN_FARKLI_LOKASYON') = 0 THEN
            odurum     := 'EKIPMAN KAYIP OLARAK ISARETLENMIS FAKAT DEPO KODU YTS KODU SEÇILMIS.';
            oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
            RETURN;
         END IF;
      END IF;

      --eski ekipman dogru üyede
      ----------------------------------
      IF v_old_account_number = iuye_no THEN
         --Eski ekipmanin durumuna göre
         --YTS deposuna atilir
         --KAYIP deposuna atilir
         beski_ekipm_uyeye_at          := FALSE;
         bhatali_ekipm_inv_deposuna_at := FALSE;
         beski_ekipm_yts_kayip_depo_at := TRUE;
      --eski ekipman dogru üyede degil veya depoda
      -----------------------------------------------
      ELSE
         --eski ekipman kayip çalinti deposunda mi?
         IF TRIM (v_old_equip_location_code) IS NOT NULL AND v_old_account_number = 0 THEN
            SELECT COUNT (1)
              INTO v_eski_depo_kayip_count
              FROM wiz_equip_location_codes
             WHERE ust_depo_kod = 'KAYIP/CALINTI' AND equip_location_code = v_old_equip_location_code;
         ELSIF TRIM (v_old_equip_location_code) IS NOT NULL THEN
            odurum     := 'ÜYE BILGISI VE LOKASYON KODU ELDE EDILEMEDI.';
            oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
            RETURN;
         END IF;

         --outlet bilgisi yok ise bul...
         IF TRIM (ioutlet_location) IS NULL THEN
            --            SELECT COUNT (DISTINCT (outlet_location))
            --              INTO v_count
            --              FROM wiz_equip
            --             WHERE account_number = iuye_no;
            SELECT COUNT (1)
              INTO v_count
              FROM (SELECT DISTINCT (outlet_location)
                      FROM wiz_equip
                     WHERE account_number = iuye_no
                    UNION
                    SELECT DISTINCT (outlet_location)
                      FROM eq_ekipman
                     WHERE account_number = iuye_no);

            IF v_count > 1 THEN
               odurum     := 'ÜYENIN BIRDEN FAZLA OUTLETI VAR. OUTLET SEÇINIZ.';
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            ELSIF v_count = 0 THEN
               odurum     := 'ÜYENIN OUTLETI ELDE EDILEMEDI. OUTLET SEÇINIZ.';
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            ELSE
               --üyenin tek outleti var o kullanilacak
               --problem yok
               buyenin_tek_outleti_var := TRUE;
            END IF;
         --outlet bilgisi var ise bulunan ile uyumlu mu?
         ELSIF TRIM (v_outlet_location) IS NOT NULL AND (TRIM (ioutlet_location) <> TRIM (v_outlet_location)) AND v_old_account_number = iuye_no THEN
            odurum     := 'ÜYE OUTLETI ILE EKIPMAN OUTLETI FARKLI.DOGRU OUTLETI SEÇINIZ.';
            oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
            RETURN;
         --outlet bilgisi var, ekrandan girilmis ve o kullanilacak ise
         --problem yok o outleti kontrol et
         ELSE
            NULL;
         END IF;
      END IF;

      --varolan tek bir outletten islem yapilabilir durumda
      --isleme devam et
      IF TRIM (v_outlet_location) IS NULL AND TRIM (ioutlet_location) IS NOT NULL THEN
         v_outlet_location := TRIM (ioutlet_location);
      ELSIF TRIM (v_outlet_location) IS NULL AND TRIM (ioutlet_location) IS NULL THEN
         odurum     := 'ÜYE OUTLETI BULUNAMADI.DOGRU OUTLETI SEÇINIZ.';
         oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
         RETURN;
      END IF;

      IF (v_old_account_number <> iuye_no) AND (buyenin_tek_outleti_var OR TRIM (ioutlet_location) IS NOT NULL) THEN
         BEGIN
            IF TRIM (ioutlet_location) IS NULL THEN
               --               SELECT serial_number, outlet_location
               --                 INTO v_hatali_serial_number, v_outlet_location
               --                 FROM wiz_equip
               --                WHERE account_number = iuye_no
               --                  AND converter_type = v_old_converter_type;
               BEGIN
                  SELECT serial_number, outlet_location
                    INTO v_hatali_serial_number, v_outlet_location
                    FROM wiz_equip
                   WHERE account_number = iuye_no AND converter_type = v_old_converter_type;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT serial_number, outlet_location
                       INTO v_hatali_serial_number, v_outlet_location
                       FROM eq_ekipman
                      WHERE account_number = iuye_no AND ekipman_tipi = v_old_converter_type;
               END;
            ELSE
               --               SELECT serial_number
               --                 INTO v_hatali_serial_number
               --                 FROM wiz_equip
               --                WHERE account_number = iuye_no
               --                  AND outlet_location = TRIM (ioutlet_location)
               --                  AND converter_type = v_old_converter_type;
               BEGIN
                  SELECT serial_number
                    INTO v_hatali_serial_number
                    FROM wiz_equip
                   WHERE account_number = iuye_no AND outlet_location = TRIM (ioutlet_location) AND converter_type = v_old_converter_type;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT serial_number
                       INTO v_hatali_serial_number
                       FROM eq_ekipman
                      WHERE account_number = iuye_no AND outlet_location = TRIM (ioutlet_location) AND ekipman_tipi = v_old_converter_type;
               END;
            END IF;

            --baska bir ekipman o outlette var ise
            --üyedeki ekipman INV deposuna atilir
            --beyan edilen ekipman üyeye verilir
            --sonra YTS deposuna atilir
            --yeni ekipman üyeye verilir

            --eski ekipman baska üyede
            ----------------------------------
            IF v_old_account_number > 0 AND v_old_account_number <> iuye_no THEN
               --eski ekipman baska üyede ve YTS deposu
               --eski ekipman baska üyede ve kayip deposu
               --yeni ekipman üyeye verilir
               beski_ekipm_uyeye_at          := FALSE;
               bhatali_ekipm_inv_deposuna_at := TRUE;
               beski_ekipm_yts_kayip_depo_at := FALSE;
            END IF;

            --eski ekipman YTS deposunda ve kayip degil
            --ya da
            --eski ekipman YTS deposunda ve kayip
            IF v_old_account_number = 0 AND v_eski_depo_kayip_count = 0 THEN
               beski_ekipm_uyeye_at          := TRUE;
               bhatali_ekipm_inv_deposuna_at := TRUE;
               beski_ekipm_yts_kayip_depo_at := TRUE;
            --eski ekipman KAYIP deposunda
            ELSIF v_old_account_number = 0 AND v_eski_depo_kayip_count > 0 THEN
               --ve kayip degil
               IF v_yeni_depo_kayip_count = 0 THEN
                  beski_ekipm_uyeye_at          := TRUE;
                  bhatali_ekipm_inv_deposuna_at := TRUE;
                  beski_ekipm_yts_kayip_depo_at := TRUE;
               --ve kayip
               --yeni ekipman üyeye verilir
               ELSE
                  beski_ekipm_uyeye_at          := FALSE;
                  bhatali_ekipm_inv_deposuna_at := TRUE;
                  beski_ekipm_yts_kayip_depo_at := FALSE;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               --baska bir ekipman o outlette yok ise
               --ekipman üyeye verilir
               --sonra YTS deposuna atilir
               --yeni ekipman üyeye verilir

               --eski ekipman baska üyede
               ----------------------------------
               IF v_old_account_number > 0 AND v_old_account_number <> iuye_no THEN
                  --eski ekipman baska üyede ve YTS deposu
                  --eski ekipman baska üyede ve kayip deposu
                  --yeni ekipman üyeye verilir
                  beski_ekipm_uyeye_at          := FALSE;
                  bhatali_ekipm_inv_deposuna_at := FALSE;
                  beski_ekipm_yts_kayip_depo_at := FALSE;
               END IF;

               --eski ekipman YTS deposunda ve kayip degil
               --ya da
               --eski ekipman YTS deposunda ve kayip
               IF v_old_account_number = 0 AND v_eski_depo_kayip_count = 0 THEN
                  beski_ekipm_uyeye_at          := TRUE;
                  bhatali_ekipm_inv_deposuna_at := FALSE;
                  beski_ekipm_yts_kayip_depo_at := TRUE;
               --eski ekipman KAYIP deposunda
               ELSIF v_old_account_number = 0 AND v_eski_depo_kayip_count > 0 THEN
                  --ve kayip degil
                  IF v_yeni_depo_kayip_count = 0 THEN
                     beski_ekipm_uyeye_at          := TRUE;
                     bhatali_ekipm_inv_deposuna_at := FALSE;
                     beski_ekipm_yts_kayip_depo_at := TRUE;
                  --ve kayip
                  --yeni ekipman üyeye verilir
                  ELSE
                     beski_ekipm_uyeye_at          := FALSE;
                     bhatali_ekipm_inv_deposuna_at := FALSE;
                     beski_ekipm_yts_kayip_depo_at := FALSE;
                  END IF;
               END IF;
         END;
      END IF;

      --Hersey OK ise islemleri yap
      IF v_iris_kullanici = 0 THEN
         UPDATE lg_teknik_servis_sifre
            SET ts_form_no = its_form_no
          WHERE id = ilg_teknik_servis_sifre_id AND ts_form_no IS NULL;
      END IF;

      IF TRIM (ioutlet_location) IS NOT NULL THEN
         v_outlet_location := TRIM (ioutlet_location);
      ELSIF TRIM (v_outlet_location) IS NULL AND TRIM (ioutlet_location) IS NULL THEN
         odurum     := 'ÜYE OUTLETI BULUNAMADI.DOGRU OUTLETI SEÇINIZ.';
         oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
         RETURN;
      END IF;

      IF     (TRIM (ioutlet_location) IS NOT NULL)
         AND (TRIM (v_outlet_location) IS NOT NULL)
         AND TRIM (ioutlet_location) <> TRIM (v_outlet_location)
         AND TRIM (iuye_no) = TRIM (v_old_account_number) THEN
         odurum     := 'SEÇILEN OUTLET ILE EKIPMAN OUTLETLERI FARKLI.';
         oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
         RETURN;
      END IF;

      /*--- Evren --- 20120414 --- begin ---*/
      IF v_new_converter_type = 'ST' THEN
         ekipman_ozellik (inew_serial_number, NULL, NULL, 33, v_new_ekipman_tip_matrix_id, v_new_hd_destekli);

         ekipman_ozellik (iold_serial_number, NULL, NULL, 33, v_old_ekipman_tip_matrix_id, v_old_hd_destekli);

         --Mesut Alpaslan : (24.04.2012) - son bir gün içinde ilgili memo varsa yeni kutu HD olsada değişim yapılabilir.
         SELECT COUNT (1)
           INTO v_memo_count
           FROM co_memo_bilgi
          WHERE     memo_kodu IN (SELECT TO_NUMBER (COLUMN_VALUE) AS val
                                    FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit (TRIM ('EKIPMAN_DEGISIM_MATRIX_KISIT_GEC_MEMO_KODU')))))
                AND abone_kodu = iuye_no
                AND acilis_tarihi > SYSDATE - 1;

         SELECT COUNT (1)
           INTO v_count
           FROM wiz_customer_hp_life life
          WHERE life.account_number = iuye_no AND life.franchise_code = 'F01' AND life.customer_type = 'NOR';

         IF     abone_sorgu_pack.hd_servisi_varmi (iuye_no, ioutlet_location) = 0
            AND v_new_hd_destekli = 'E'
            AND v_old_hd_destekli = 'E'
            AND yetki_pack.yetkisi_varmi (igiren_kullanici, 'ISLEM_HD_EKIPMAN_DEGISIM', 1) = 0
            AND v_memo_count = 0
            AND v_count = 0 THEN
            odurum     := 'BU UYE/OUTLETE HD EKIPMAN VERILEMEZ';
            oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
            RETURN;
         END IF;
      END IF;

      /*--- Evren --- 20120414 --- end ---*/

      /*--- Evren --- 20110414 --- begin ---*/
      IF (v_franchise_code IN ('F01', 'F02') AND v_stb_tipi IN ('LG', 'VS') AND v_new_converter_type <> 'SC') OR ialt_islem_tipi = 'KEN_DEGISIM' THEN
         get_ekipman_tip_matrix (inew_serial_number, v_new_ekipman_tip_matrix_id, odurum);

         IF odurum <> '0' THEN
            oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
            RETURN;
         END IF;

         IF v_new_converter_type = 'ST' THEN
            ekipman_transfer_edilebilir_mi (iold_serial_number,
                                            v_new_ekipman_tip_matrix_id,
                                            1,
                                            out_result,
                                            odurum,
                                            oproc_name,
                                            oerror_type,
                                            oerror_code,
                                            oerror_text
                                           );

            IF odurum <> '0' THEN
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            END IF;
         ELSE
            eq_ekipman_pack.ekipman_transfer_edilebilir_mi (iold_serial_number, v_new_ekipman_tip_matrix_id, out_result, odurum);

            IF odurum <> '0' THEN
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            END IF;
         END IF;

         IF out_result NOT IN ('1', '3', '5') THEN
            IF ekipman_satilikmi (inew_serial_number, NULL, NULL, v_new_equip_location_code) <> 'E' THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM eq_ekipman_sahibi_kim
                WHERE serial_number = inew_serial_number AND kayit_iptal = 'H' AND ekipman_sahibi_tipi = 1;

               IF v_count = 0 THEN
                  ekipman_pack.eq_ekipman_sahibi_kim_ins_upd (inew_serial_number,
                                                              iuye_no,
                                                              ioutlet_location,
                                                              vekipman_tipi,
                                                              NULL,
                                                              'EDS',
                                                              1,
                                                              'EKIPMAN DEGISIMI OTOMATIK GECICI SAHIPLIK',
                                                              NULL,
                                                              'H',
                                                              'SYSTEM',
                                                              NULL,
                                                              dbs_sabit ('BRAND_DEGISIKLIGI_OTOMATIK_GECICI_SAHIPLIK'),
                                                              its_no, --'vsales_agent_code,
                                                              v_new_ekipman_tip_matrix_id,
                                                              oerror_text,
                                                              odurum,
                                                              'H'
                                                             );

                  IF odurum <> '0' THEN
                     oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
                     RETURN;
                  END IF;
               END IF;
            END IF;
         ELSIF out_result = 5 THEN
            -- Ken ve modem için eskisinin sahipliği var yenisinin sahipliği yok ise o zaman transfer et.
            SELECT COUNT (1)
              INTO v_count
              FROM eq_ekipman_sahibi_kim
             WHERE serial_number = iold_serial_number AND kayit_iptal = 'H' AND ekipman_sahibi_tipi = 1;

            IF v_count > 0 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM eq_ekipman_sahibi_kim
                WHERE serial_number = inew_serial_number AND kayit_iptal = 'H' AND ekipman_sahibi_tipi = 1;

               IF v_count = 0 THEN
                  ekipman_pack.eq_ekipman_sahibi_kim_transfer (iold_serial_number,
                                                               inew_serial_number,
                                                               iuye_no,
                                                               ioutlet_location,
                                                               'EKD',
                                                               'EKD',
                                                               'EKIPMAN DEĞİŞİKLİĞİ',
                                                               igiren_kullanici,
                                                               odurum
                                                              );
               END IF;
            END IF;
         END IF;
      END IF;

      /*--- Evren --- 20110414 --- end ---*/
      IF bhatali_ekipm_inv_deposuna_at THEN
         IF iok = '0:E' THEN
            odurum      :=    '1:E ÜYENIN OUTLETINDE BASKA BIR EKIPMAN BULUNMAKTADIR.'
                           || CHR (10)
                           || CHR (13)
                           || 'BU EKIPMANIN INVALID DEPOSUNA ATILMASINI ONAYLIYOR MUSUNUZ?';
            RETURN;
         --kullanici OK lerse islemi yap
         ELSIF iok = '1:E' OR iok = '2:E' OR iok = '3:E' THEN
            --            ekipman_pack.ekipman_cikar (iuye_no,
            --                                        v_hatali_serial_number,
            --                                        v_outlet_location,
            --                                        its_no,
            --                                        its_form_no,
            --                                        v_reason_code,           --YTS TELEFON
            --                                        'INV',
            --                                        v_service_address_id,
            --                                        igiren_kullanici,
            --                                        iotorizasyon_no,
            --                                        ilg_teknik_servis_sifre_id,
            --                                        in_aciklama,
            --                                        odurum,
            --                                        v_taa_uyari,
            --                                        oproc_name,
            --                                        ois_emri,
            --                                        v_error_type,
            --                                        v_error_code,
            --                                        v_error_text
            --                                       );
            eq_ekipman_pack.eq_ekipman_cikar (iuye_no, -->i_account_number        IN       NUMBER,
                                              'INV', --> i_equip_location_code   IN       CHAR,
                                              v_reason_code, --> i_reason_code           IN       CHAR,
                                              v_outlet_location, --> i_outlet_location       IN       CHAR,
                                              vekipman_tipi, --> i_ekipman_tipi          IN       NUMBER,
                                              v_hatali_serial_number, --> i_serial_number         IN       VARCHAR2,
                                              its_no, --> i_sales_agent_code      IN       VARCHAR2,
                                              in_aciklama, --> i_aciklama              IN       VARCHAR2,
                                              igiren_kullanici, --> i_kisi                  IN       VARCHAR2,
                                              SYSDATE, --> i_islem_tarihi          IN       DATE,
                                              ilg_teknik_servis_sifre_id, --> i_ts_sifre_id           IN       NUMBER,
                                              iotorizasyon_no, --> i_its_kayit_no          IN       VARCHAR2,
                                              its_form_no, --> i_ts_form_no            IN       VARCHAR2,
                                              odurum, --> o_durum                 OUT      VARCHAR2,
                                              v_taa_uyari --> o_taa_uyari             OUT      VARCHAR2
                                             );

            IF odurum <> '0' THEN
               RETURN;
            END IF;

            --            IF TRIM (v_new_converter_type) = 'SC'
            --            THEN
            --               addressability_pack.pin_kodu_sifirlama (v_hatali_serial_number, igiren_kullanici, odurum);
            --            END IF;
            v_hatali_ekipm_inv_depo_at := 'E';
         END IF;
      END IF;

      IF yyetki_ekipmani_uyeye_atama > 0 AND beski_ekipm_uyeye_at THEN
         IF iok = '0:E' OR iok = '1:E' THEN
            odurum := '2:E ESKI EKIPMAN ÜYEYE VERILIP TEKRAR BELIRTILEN DEPOYA ATILACAKTIR.' || CHR (10) || CHR (13) || 'BU ISLEMLERI ONAYLIYOR MUSUNUZ?';
            RETURN;
         --kullanici OK lerse islemi yap
         ELSIF iok = '2:E' OR iok = '3:E' THEN
            --            ekipman_pack.ekipman_ekle (iuye_no,
            --                                       iold_serial_number,
            --                                       v_outlet_location,
            --                                       its_no,
            --                                       its_form_no,
            --                                       v_reason_code,            --YTS TELEFON
            --                                       NULL,
            --                                       v_service_address_id,
            --                                       'N',
            --                                       'N',
            --                                       igiren_kullanici,
            --                                       iotorizasyon_no,
            --                                       ilg_teknik_servis_sifre_id,
            --                                       NULL,                     --sozlesme_no
            --                                       in_aciklama,
            --                                       odurum,
            --                                       oproc_name,
            --                                       ois_emri,
            --                                       v_error_type,
            --                                       v_error_code,
            --                                       v_error_text
            --                                      );
            eq_ekipman_pack.eq_ekipman_ekle (iuye_no, -->i_account_number        IN       NUMBER,
                                             v_reason_code, --> i_reason_code           IN       CHAR
                                             v_outlet_location, --> i_outlet_location       IN       CHAR,
                                             vekipman_tipi, --> i_ekipman_tipi          IN       NUMBER,
                                             NULL,
                                             vekipman_modul_tipi,
                                             iold_serial_number, --> i_serial_number          IN       VARCHAR2,
                                             its_no, --> i_sales_agent_code      IN       VARCHAR2,
                                             SYSDATE, --> i_kurulum_tarihi         IN       DATE,
                                             in_aciklama, --> i_aciklama              IN       VARCHAR2,
                                             igiren_kullanici, --> i_kisi                  IN       VARCHAR2,
                                             SYSDATE, --> i_islem_tarihi          IN       DATE,
                                             'H', --> i_kontratsiz_aktifleme   IN       VARCHAR2,
                                             'H', --> i_otel_mi                IN       VARCHAR2,
                                             NULL, --> i_sozlesme               IN       VARCHAR2,
                                             ilg_teknik_servis_sifre_id, --> i_ts_sifre_id           IN       NUMBER,
                                             iotorizasyon_no, --> i_its_kayit_no          IN       VARCHAR2,
                                             its_form_no, --> i_ts_form_no            IN       VARCHAR2,
                                             oeq_ekipman_id, --> o_id                     OUT      NUMBER,
                                             odurum --> o_durum                 OUT      VARCHAR2,
                                            );

            --   if (odurum = 'BU EKIPMANI BU DEPODAN UYEYE VERME YETKINIZ YOK.' or
            --        odurum = 'YENI KART, KULLANILAMAZ KARTLAR ARASINDA.ÜYEYE VERILEMEZ.' or
            --        odurum = 'YENI KART AKTIF DURUMDA DEGIL.ÜYEYE VERILEMEZ.') then
            IF odurum <> 0 THEN
               IF iok = '0:E' OR iok = '1:E' OR iok = '2:E' THEN
                  odurum := '3:E ESKI EKIPMAN ÜYEYE VERILEMEDI.' || CHR (10) || CHR (13) || odurum || CHR (10) || CHR (13) || 'DEVAM ETMEK ISTIYOR MUSUNUZ?';
                  RETURN;
               END IF;

               IF iok = '3:E' THEN
                  beski_ekipm_uyeye_at := FALSE;
               ELSE
                  RETURN;
               END IF;
            END IF;

            v_eski_ekipm_uyeye_atildi := 'E';
         END IF;
      END IF;

      IF    (yyetki_ekipmani_uyeye_atama > 0 AND beski_ekipm_uyeye_at AND beski_ekipm_yts_kayip_depo_at)
         OR (beski_ekipm_yts_kayip_depo_at AND v_old_account_number = iuye_no) THEN
         --         ekipman_pack.ekipman_cikar (iuye_no,
         --                                     iold_serial_number,
         --                                     v_outlet_location,
         --                                     its_no,
         --                                     its_form_no,
         --                                     v_reason_code,              --YTS TELEFON
         --                                     TRIM (idepo_kodu),
         --                                     v_service_address_id,
         --                                     igiren_kullanici,
         --                                     iotorizasyon_no,
         --                                     ilg_teknik_servis_sifre_id,
         --                                     in_aciklama,
         --                                     odurum,
         --                                     v_taa_uyari,
         --                                     oproc_name,
         --                                     ois_emri,
         --                                     v_error_type,
         --                                     v_error_code,
         --                                     v_error_text
         --                                    );
         eq_ekipman_pack.eq_ekipman_cikar (iuye_no, -->i_account_number        IN       NUMBER,
                                           TRIM (idepo_kodu), --> i_equip_location_code   IN       CHAR,
                                           v_reason_code, --> i_reason_code           IN       CHAR,
                                           v_outlet_location, --> i_outlet_location       IN       CHAR,
                                           vekipman_tipi, --> i_ekipman_tipi          IN       NUMBER,
                                           iold_serial_number, --> i_serial_number         IN       VARCHAR2,
                                           its_no, --> i_sales_agent_code      IN       VARCHAR2,
                                           in_aciklama, --> i_aciklama              IN       VARCHAR2,
                                           igiren_kullanici, --> i_kisi                  IN       VARCHAR2,
                                           SYSDATE, --> i_islem_tarihi          IN       DATE,
                                           ilg_teknik_servis_sifre_id, --> i_ts_sifre_id           IN       NUMBER,
                                           iotorizasyon_no, --> i_its_kayit_no          IN       VARCHAR2,
                                           its_form_no, --> i_ts_form_no            IN       VARCHAR2,
                                           odurum, --> o_durum                 OUT      VARCHAR2,
                                           v_taa_uyari --> o_taa_uyari             OUT      VARCHAR2
                                          );

         IF odurum <> '0' THEN
            RETURN;
         END IF;

         --         IF TRIM (v_new_converter_type) = 'SC'
         --         THEN
         --            addressability_pack.pin_kodu_sifirlama (iold_serial_number, igiren_kullanici, odurum);
         --         END IF;
         v_eski_ekipm_yts_kayip_at := 'E';
      END IF;

      --yeni ekipman her durumda eklenecek
      /*      ekipman_pack.ekipman_ekle (iuye_no,
                                       inew_serial_number,
                                       v_outlet_location,
                                       its_no,
                                       its_form_no,
                                       v_reason_code,                  --YTS TELEFON
                                       NULL,
                                       v_service_address_id,
                                       'N',
                                       'N',
                                       igiren_kullanici,
                                       iotorizasyon_no,
                                       ilg_teknik_servis_sifre_id,
                                       NULL,                           --sozlesme_no
                                       in_aciklama,
                                       odurum,
                                       oproc_name,
                                       ois_emri,
                                       v_error_type,
                                       v_error_code,
                                       v_error_text
                                      );
       */
      eq_ekipman_pack.eq_ekipman_ekle (iuye_no, -->i_account_number        IN       NUMBER,
                                       v_reason_code, --> i_reason_code           IN       CHAR
                                       v_outlet_location, --> i_outlet_location       IN       CHAR,
                                       vekipman_tipi, --> i_ekipman_tipi          IN       NUMBER,
                                       NULL, --> Ekipman kutu tipi
                                       vekipman_modul_tipi,
                                       inew_serial_number, --> i_serial_number          IN       VARCHAR2,
                                       its_no, --> i_sales_agent_code      IN       VARCHAR2,
                                       SYSDATE, --> i_kurulum_tarihi         IN       DATE,
                                       in_aciklama, --> i_aciklama              IN       VARCHAR2,
                                       igiren_kullanici, --> i_kisi                  IN       VARCHAR2,
                                       SYSDATE, --> i_islem_tarihi          IN       DATE,
                                       'H', --> i_kontratsiz_aktifleme   IN       VARCHAR2,
                                       'H', --> i_otel_mi                IN       VARCHAR2,
                                       NULL, --> i_sozlesme               IN       VARCHAR2,
                                       ilg_teknik_servis_sifre_id, --> i_ts_sifre_id           IN       NUMBER,
                                       iotorizasyon_no, --> i_its_kayit_no          IN       VARCHAR2,
                                       its_form_no, --> i_ts_form_no            IN       VARCHAR2,
                                       oeq_ekipman_id, --> o_id                     OUT      NUMBER,
                                       odurum --> o_durum                 OUT      VARCHAR2,
                                      );

      IF odurum <> '0' THEN
         RETURN;
      END IF;

      IF v_iris_kullanici = 0 THEN
         IF ialt_islem_tipi = 'SC_DEGISIM' THEN
            ekipman_pack.lg_telefon_ekipm_islem_ins_upd (1,
                                                         1,
                                                         iotorizasyon_no,
                                                         ilg_teknik_servis_sifre_id,
                                                         its_no,
                                                         v_old_equip_location_code,
                                                         NULL,
                                                         NULL,
                                                         iuye_no,
                                                         v_outlet_location,
                                                         iold_serial_number,
                                                         NULL,
                                                         NULL,
                                                         inew_serial_number,
                                                         NULL,
                                                         NULL,
                                                         v_hatali_serial_number,
                                                         NULL,
                                                         NULL,
                                                         iekipman_kayip,
                                                         NULL,
                                                         NULL,
                                                         its_form_no,
                                                         in_aciklama,
                                                         v_eski_ekipm_uyeye_atildi,
                                                         v_hatali_ekipm_inv_depo_at,
                                                         v_eski_ekipm_yts_kayip_at,
                                                         'H',
                                                         'H',
                                                         'H',
                                                         'H',
                                                         'H',
                                                         'H',
                                                         igiren_kullanici,
                                                         odurum
                                                        );
         ELSIF ialt_islem_tipi = 'STB_DEGISIM' THEN
            ekipman_pack.lg_telefon_ekipm_islem_ins_upd (1,
                                                         2,
                                                         iotorizasyon_no,
                                                         ilg_teknik_servis_sifre_id,
                                                         its_no,
                                                         NULL,
                                                         v_old_equip_location_code,
                                                         NULL,
                                                         iuye_no,
                                                         v_outlet_location,
                                                         NULL,
                                                         iold_serial_number,
                                                         NULL,
                                                         NULL,
                                                         inew_serial_number,
                                                         NULL,
                                                         NULL,
                                                         v_hatali_serial_number,
                                                         NULL,
                                                         NULL,
                                                         iekipman_kayip,
                                                         NULL,
                                                         its_form_no,
                                                         in_aciklama,
                                                         'H',
                                                         'H',
                                                         'H',
                                                         v_eski_ekipm_uyeye_atildi,
                                                         v_hatali_ekipm_inv_depo_at,
                                                         v_eski_ekipm_yts_kayip_at,
                                                         'H',
                                                         'H',
                                                         'H',
                                                         igiren_kullanici,
                                                         odurum
                                                        );
         ELSE -- ELSEIF ialt_islem_tipi = 'MD_DEGISIM' THEN
            ekipman_pack.lg_telefon_ekipm_islem_ins_upd (1,
                                                         3,
                                                         iotorizasyon_no,
                                                         ilg_teknik_servis_sifre_id,
                                                         its_no,
                                                         NULL,
                                                         NULL,
                                                         v_old_equip_location_code,
                                                         iuye_no,
                                                         v_outlet_location,
                                                         NULL,
                                                         NULL,
                                                         iold_serial_number,
                                                         NULL,
                                                         NULL,
                                                         inew_serial_number,
                                                         NULL,
                                                         NULL,
                                                         v_hatali_serial_number,
                                                         NULL,
                                                         NULL,
                                                         iekipman_kayip,
                                                         its_form_no,
                                                         in_aciklama,
                                                         'H',
                                                         'H',
                                                         'H',
                                                         'H',
                                                         'H',
                                                         'H',
                                                         v_eski_ekipm_uyeye_atildi,
                                                         v_hatali_ekipm_inv_depo_at,
                                                         v_eski_ekipm_yts_kayip_at,
                                                         igiren_kullanici,
                                                         odurum
                                                        );
         END IF;
      END IF;

      IF odurum <> '0' THEN
         RETURN;
      END IF;

      -- Ozgur Arslan Ekipman Degisimde Gecici sahipliklerin iptali yapılmalı
      -- 27,02,2012

      FOR rec IN (SELECT *
                    FROM eq_ekipman_sahibi_kim
                   WHERE (serial_number = iold_serial_number) AND kayit_iptal = 'H' AND ekipman_sahibi_tipi = 1 AND sahiplik_tipi = 1) LOOP
         eq_ekipman_sahibi_kim_ins_upd (rec.serial_number,
                                        rec.account_number,
                                        rec.outlet_location,
                                        rec.ekipman_tipi,
                                        rec.sales_agent_code,
                                        rec.sebep_kodu,
                                        rec.ekipman_sahibi_tipi,
                                        'EKIPMAN DEGISIM GECICI SAHIPLIK IPTAL',
                                        v_reason_code,
                                        'E',
                                        igiren_kullanici,
                                        NULL,
                                        rec.kampanya_kodu,
                                        rec.satis_bayi_kodu,
                                        NULL,
                                        v_taa_uyari,
                                        odurum,
                                        NULL
                                       );
      END LOOP;

      IF odurum <> '0' THEN
         oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
         RETURN;
      END IF;

      bt_uye_ts_pack.bt_uye_ts_guncel_feed (iuye_no, ioutlet_location, its_no, 3, --IN_YTS_ISLEM_TIPI
                                                                                 'C', --IN_STATUS
                                                                                     NULL, --IN_MEMO_KOD,
                                                                                          NULL, --IN_SEBEP_KOD,
                                                                                               4, --IN_EKRAN_KOD
                                                                                                 igiren_kullanici, 'VALIDASYON EKIPMAN DEGISIM', odurum);

      IF odurum <> '0' THEN
         oproc_name := 'BT_UYE_TS_GUNCEL_FEED';
         RETURN;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         odurum     := SQLERRM;
         oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
         RETURN;
   END telefon_ekipman_degisim;

   PROCEDURE lg_ekipman_sahibi_kim_insert (in_islem                   IN     lg_ekipman_sahibi_kim.islem%TYPE,
                                           in_kisi                    IN     lg_ekipman_sahibi_kim.kisi%TYPE,
                                           in_serial_number           IN     lg_ekipman_sahibi_kim.serial_number%TYPE,
                                           in_account_number          IN     lg_ekipman_sahibi_kim.account_number%TYPE,
                                           in_outlet_location         IN     lg_ekipman_sahibi_kim.outlet_location%TYPE,
                                           in_sales_agent_code        IN     lg_ekipman_sahibi_kim.sales_agent_code%TYPE,
                                           in_sebep_kodu              IN     lg_ekipman_sahibi_kim.sebep_kodu%TYPE,
                                           in_ekipman_sahibi_tipi     IN     lg_ekipman_sahibi_kim.ekipman_sahibi_tipi%TYPE,
                                           in_aciklama                IN     lg_ekipman_sahibi_kim.aciklama%TYPE,
                                           in_iptal_sebep_kodu        IN     lg_ekipman_sahibi_kim.iptal_sebep_kodu%TYPE,
                                           in_kayit_iptal             IN     lg_ekipman_sahibi_kim.kayit_iptal%TYPE,
                                           in_kampanya_kodu           IN     lg_ekipman_sahibi_kim.kampanya_kodu%TYPE,
                                           in_satis_bayi_kodu         IN     lg_ekipman_sahibi_kim.satis_bayi_kodu%TYPE,
                                           in_kampanya_ozellik_kodu   IN     lg_ekipman_sahibi_kim.kampanya_ozellik_kodu%TYPE,
                                           in_kampanya_ozellik_degeri IN     lg_ekipman_sahibi_kim.kampanya_ozellik_degeri%TYPE,
                                           in_sahiplik_tipi           IN     lg_ekipman_sahibi_kim.sahiplik_tipi%TYPE,
                                           in_ekipman_tipi            IN     lg_ekipman_sahibi_kim.ekipman_tipi%TYPE,
                                           in_sahiplik_id             IN     lg_ekipman_sahibi_kim.sahiplik_id%TYPE,
                                           in_garanti_baslangic       IN     lg_ekipman_sahibi_kim.garanti_baslangic%TYPE,
                                           odurum                        OUT VARCHAR2
                                          ) IS
      v_islem                   lg_ekipman_sahibi_kim.islem%TYPE;
      v_kisi                    lg_ekipman_sahibi_kim.kisi%TYPE;
      v_serial_number           lg_ekipman_sahibi_kim.serial_number%TYPE;
      v_account_number          lg_ekipman_sahibi_kim.account_number%TYPE;
      v_outlet_location         lg_ekipman_sahibi_kim.outlet_location%TYPE;
      v_sales_agent_code        lg_ekipman_sahibi_kim.sales_agent_code%TYPE;
      v_sebep_kodu              lg_ekipman_sahibi_kim.sebep_kodu%TYPE;
      v_ekipman_sahibi_tipi     lg_ekipman_sahibi_kim.ekipman_sahibi_tipi%TYPE;
      v_aciklama                lg_ekipman_sahibi_kim.aciklama%TYPE;
      v_iptal_sebep_kodu        lg_ekipman_sahibi_kim.iptal_sebep_kodu%TYPE;
      v_kayit_iptal             lg_ekipman_sahibi_kim.kayit_iptal%TYPE;
      v_kampanya_kodu           lg_ekipman_sahibi_kim.kampanya_kodu%TYPE;
      v_satis_bayi_kodu         lg_ekipman_sahibi_kim.satis_bayi_kodu%TYPE;
      v_kampanya_ozellik_kodu   lg_ekipman_sahibi_kim.kampanya_ozellik_kodu%TYPE;
      v_kampanya_ozellik_degeri lg_ekipman_sahibi_kim.kampanya_ozellik_degeri%TYPE;
      v_sahiplik_tipi           lg_ekipman_sahibi_kim.sahiplik_tipi%TYPE;
      v_ekipman_tipi            lg_ekipman_sahibi_kim.ekipman_tipi%TYPE;
      v_sahiplik_id             lg_ekipman_sahibi_kim.sahiplik_id%TYPE;
      v_garanti_baslangic       lg_ekipman_sahibi_kim.garanti_baslangic%TYPE;
   BEGIN
      odurum                    := '0';
      v_islem                   := in_islem;
      v_kisi                    := in_kisi;
      v_serial_number           := in_serial_number;
      v_account_number          := in_account_number;
      v_outlet_location         := in_outlet_location;
      v_sales_agent_code        := in_sales_agent_code;
      v_sebep_kodu              := in_sebep_kodu;
      v_ekipman_sahibi_tipi     := in_ekipman_sahibi_tipi;
      v_aciklama                := in_aciklama;
      v_iptal_sebep_kodu        := in_iptal_sebep_kodu;
      v_kayit_iptal             := in_kayit_iptal;
      v_kampanya_kodu           := in_kampanya_kodu;
      v_satis_bayi_kodu         := in_satis_bayi_kodu;
      v_kampanya_ozellik_kodu   := in_kampanya_ozellik_kodu;
      v_kampanya_ozellik_degeri := in_kampanya_ozellik_degeri;
      v_sahiplik_tipi           := in_sahiplik_tipi;
      v_ekipman_tipi            := in_ekipman_tipi;
      v_sahiplik_id             := in_sahiplik_id;
      v_garanti_baslangic       := in_garanti_baslangic;

      INSERT
        INTO lg_ekipman_sahibi_kim (id,
                                    islem,
                                    kisi,
                                    tarih,
                                    serial_number,
                                    account_number,
                                    outlet_location,
                                    sales_agent_code,
                                    sebep_kodu,
                                    ekipman_sahibi_tipi,
                                    aciklama,
                                    iptal_sebep_kodu,
                                    kayit_iptal,
                                    kampanya_kodu,
                                    satis_bayi_kodu,
                                    kampanya_ozellik_kodu,
                                    kampanya_ozellik_degeri,
                                    sahiplik_tipi,
                                    ekipman_tipi,
                                    sahiplik_id,
                                    garanti_baslangic
                                   )
         VALUES (
                   lg_ekipman_sahibi_kim_id_seq.NEXTVAL,
                   v_islem,
                   v_kisi,
                   SYSDATE,
                   v_serial_number,
                   v_account_number,
                   v_outlet_location,
                   v_sales_agent_code,
                   v_sebep_kodu,
                   v_ekipman_sahibi_tipi,
                   v_aciklama,
                   v_iptal_sebep_kodu,
                   v_kayit_iptal,
                   v_kampanya_kodu,
                   v_satis_bayi_kodu,
                   v_kampanya_ozellik_kodu,
                   v_kampanya_ozellik_degeri,
                   v_sahiplik_tipi,
                   v_ekipman_tipi,
                   v_sahiplik_id,
                   v_garanti_baslangic);
   EXCEPTION
      WHEN OTHERS THEN
         odurum := SQLERRM;
   END;

   PROCEDURE eq_ekipman_sahibi_kim_transfer (in_serial_number      IN     eq_ekipman_sahibi_kim.serial_number%TYPE,
                                             in_yeni_serial_number IN     eq_ekipman_sahibi_kim.serial_number%TYPE,
                                             in_account_number     IN     eq_ekipman_sahibi_kim.account_number%TYPE,
                                             in_outlet_location    IN     eq_ekipman_sahibi_kim.outlet_location%TYPE,
                                             in_sebep_kodu         IN     eq_ekipman_sahibi_kim.sebep_kodu%TYPE,
                                             in_iptal_sebep_kodu   IN     eq_ekipman_sahibi_kim.iptal_sebep_kodu%TYPE,
                                             in_aciklama           IN     eq_ekipman_sahibi_kim.aciklama%TYPE,
                                             in_giren_kullanici    IN     eq_ekipman_sahibi_kim.giren_kullanici%TYPE,
                                             odurum                   OUT VARCHAR2
                                            ) IS
      v_yeni_seri_no_bos            BOOLEAN;
      v_sahiplik_id                 NUMBER;
      --
      v_ittp_process_type           NUMBER;
      v_ittp_owner_sales_agent      VARCHAR2 (30);
      v_result_type                 NUMBER;
      v_result_code                 VARCHAR2 (20);
      v_result_message              VARCHAR2 (512);

      -- FAY : Sahipligin farkli aboneye yetki ile transferi
      -- ADR : Adres degisikliginde sahiplik transferi
      -- ESO : Ekipman sahipligi outlet degisikligi

      -- Bu üçünde seri no üzerindeki üye ve/veya outlet degisir
      CURSOR eq_ekipman_sahibi_seri_no  IS
         SELECT *
           FROM eq_ekipman_sahibi_kim
          WHERE serial_number = in_serial_number AND kayit_iptal = 'H';

      rec_eq_ekipman_sahibi_seri_no eq_ekipman_sahibi_seri_no%ROWTYPE;

      CURSOR eq_ekipman_sahibi_account  IS
         SELECT *
           FROM eq_ekipman_sahibi_kim
          WHERE account_number = in_account_number AND outlet_location = in_outlet_location AND kayit_iptal = 'H';

      -- EKD : Ekipman düsürme/ekleme ile gerçeklesen degisiklik
      -- Bunda üye no degil, seri no degisir
      CURSOR eq_ekipman_sahibi_seri_no_yeni  IS
         SELECT *
           FROM eq_ekipman_sahibi_kim
          WHERE serial_number = in_yeni_serial_number; -- AND

      v_converter_type              VARCHAR2 (2);

      CURSOR cur_ekipman_tipi  IS
         SELECT converter_type
           FROM wiz_equip
          WHERE serial_number = NVL (in_yeni_serial_number, in_serial_number);
   -- KAYIT_IPTAL = 'H';
   BEGIN
      -- Ocak 2008
      -- v_sebep_kodu IN ('FAY','ADR','ESO','EKD')
      -- Bu sebep kodlari sistemin kendi sahiplik güncellemesindendir, ilk satistaki kontroller yapilmaz.
      -- Sadece bayi kotasindaki abone no guncellenir.

      -- Bu sebep kodlari ekrandan seçilemiyor olmalidir. !!!

      -- FAY : Sahipligin farkli aboneye yetki ile transferi
      -- ADR : Adres degisikliginde sahiplik transferi
      -- ESO : Ekipman sahipligi outlet degisikligi
      -- EKD : Ekipman düsürme/ekleme ile gerçeklesen degisiklik

      -- Eskisini iptal edip, yeni üye için bir tane olusturur.
      -- Cursor'da sadece 1 satir gelmeli
      FOR cur_eq_ekipman_sahibi_seri_no IN eq_ekipman_sahibi_seri_no LOOP
         --Hanife Dilek 05/04/2011
         rec_eq_ekipman_sahibi_seri_no := cur_eq_ekipman_sahibi_seri_no;

         IF in_sebep_kodu = 'EKD' THEN
            -- yeni seri no ile sahiplik insert et ama, bu seri no daha önce tabloda varsa da update gerekir.
            v_yeni_seri_no_bos  := TRUE;

            FOR c_ekipman_sahibi_seri_no_yeni IN eq_ekipman_sahibi_seri_no_yeni LOOP
               IF c_ekipman_sahibi_seri_no_yeni.ekipman_sahibi_tipi = 2 THEN
                  lg_ekipman_sahibi_kim_insert ('U',
                                                in_giren_kullanici,
                                                in_yeni_serial_number,
                                                c_ekipman_sahibi_seri_no_yeni.account_number,
                                                c_ekipman_sahibi_seri_no_yeni.outlet_location,
                                                c_ekipman_sahibi_seri_no_yeni.sales_agent_code,
                                                c_ekipman_sahibi_seri_no_yeni.sebep_kodu,
                                                c_ekipman_sahibi_seri_no_yeni.ekipman_sahibi_tipi,
                                                in_aciklama,
                                                in_iptal_sebep_kodu,
                                                'E',
                                                c_ekipman_sahibi_seri_no_yeni.kampanya_kodu,
                                                c_ekipman_sahibi_seri_no_yeni.satis_bayi_kodu,
                                                c_ekipman_sahibi_seri_no_yeni.kampanya_ozellik_kodu,
                                                c_ekipman_sahibi_seri_no_yeni.kampanya_ozellik_degeri,
                                                c_ekipman_sahibi_seri_no_yeni.sahiplik_tipi,
                                                c_ekipman_sahibi_seri_no_yeni.ekipman_tipi,
                                                c_ekipman_sahibi_seri_no_yeni.sahiplik_id,
                                                c_ekipman_sahibi_seri_no_yeni.garanti_baslangic,
                                                odurum
                                               );

                  IF TRIM (odurum) != '0' THEN
                     odurum := 'Log islemi yapilamadi.' || odurum;
                     RETURN;
                  END IF;

                  v_ittp_owner_sales_agent := c_ekipman_sahibi_seri_no_yeni.sales_agent_code;
               END IF;

               v_sahiplik_id      := c_ekipman_sahibi_seri_no_yeni.sahiplik_id;

               UPDATE eq_ekipman_sahibi_kim
                  SET account_number          = in_account_number,
                      outlet_location         = in_outlet_location,
                      sebep_kodu              = in_sebep_kodu,
                      aciklama                = in_aciklama,
                      kayit_iptal             = 'H',
                      iptal_sebep_kodu        = NULL,
                      degistiren_kullanici    = in_giren_kullanici,
                      degistirme_tarihi       = SYSDATE,
                      ekipman_sahibi_tipi     = 1,
                      sales_agent_code        = NULL,
                      kampanya_kodu           = cur_eq_ekipman_sahibi_seri_no.kampanya_kodu,
                      satis_bayi_kodu         = cur_eq_ekipman_sahibi_seri_no.satis_bayi_kodu,
                      kampanya_ozellik_kodu   = cur_eq_ekipman_sahibi_seri_no.kampanya_ozellik_kodu,
                      kampanya_ozellik_degeri = cur_eq_ekipman_sahibi_seri_no.kampanya_ozellik_degeri,
                      sahiplik_tipi           = cur_eq_ekipman_sahibi_seri_no.sahiplik_tipi,
                      ekipman_tipi            = cur_eq_ekipman_sahibi_seri_no.ekipman_tipi,
                      garanti_baslangic       = cur_eq_ekipman_sahibi_seri_no.garanti_baslangic
                WHERE serial_number = in_yeni_serial_number;

               lg_ekipman_sahibi_kim_insert ('U',
                                             in_giren_kullanici,
                                             in_yeni_serial_number,
                                             in_account_number,
                                             in_outlet_location,
                                             NULL,
                                             in_sebep_kodu,
                                             1,
                                             in_aciklama,
                                             NULL,
                                             'H',
                                             cur_eq_ekipman_sahibi_seri_no.kampanya_kodu,
                                             cur_eq_ekipman_sahibi_seri_no.satis_bayi_kodu,
                                             cur_eq_ekipman_sahibi_seri_no.kampanya_ozellik_kodu,
                                             cur_eq_ekipman_sahibi_seri_no.kampanya_ozellik_degeri,
                                             cur_eq_ekipman_sahibi_seri_no.sahiplik_tipi,
                                             cur_eq_ekipman_sahibi_seri_no.ekipman_tipi,
                                             c_ekipman_sahibi_seri_no_yeni.sahiplik_id,
                                             cur_eq_ekipman_sahibi_seri_no.garanti_baslangic,
                                             odurum
                                            );

               IF TRIM (odurum) != '0' THEN
                  odurum := 'Log islemi yapilamadi.' || odurum;
                  RETURN;
               END IF;

               v_yeni_seri_no_bos := FALSE;
            END LOOP;

            IF v_yeni_seri_no_bos THEN
               SELECT eq_ekipman_sahibi_seq.NEXTVAL INTO v_sahiplik_id FROM DUAL;

               INSERT
                 INTO eq_ekipman_sahibi_kim (serial_number,
                                             account_number,
                                             outlet_location,
                                             sales_agent_code,
                                             sebep_kodu,
                                             ekipman_sahibi_tipi,
                                             aciklama,
                                             iptal_sebep_kodu,
                                             kayit_iptal,
                                             kampanya_kodu,
                                             satis_bayi_kodu,
                                             kampanya_ozellik_kodu,
                                             kampanya_ozellik_degeri,
                                             giren_kullanici,
                                             giris_tarihi,
                                             degistiren_kullanici,
                                             degistirme_tarihi,
                                             sahiplik_tipi,
                                             ekipman_tipi,
                                             garanti_baslangic,
                                             sahiplik_id
                                            )
                  VALUES (
                            in_yeni_serial_number,
                            in_account_number,
                            in_outlet_location,
                            cur_eq_ekipman_sahibi_seri_no.sales_agent_code,
                            in_sebep_kodu,
                            cur_eq_ekipman_sahibi_seri_no.ekipman_sahibi_tipi,
                            in_aciklama,
                            NULL,
                            'H',
                            cur_eq_ekipman_sahibi_seri_no.kampanya_kodu,
                            cur_eq_ekipman_sahibi_seri_no.satis_bayi_kodu,
                            cur_eq_ekipman_sahibi_seri_no.kampanya_ozellik_kodu,
                            cur_eq_ekipman_sahibi_seri_no.kampanya_ozellik_degeri,
                            in_giren_kullanici,
                            SYSDATE,
                            in_giren_kullanici,
                            SYSDATE,
                            cur_eq_ekipman_sahibi_seri_no.sahiplik_tipi,
                            cur_eq_ekipman_sahibi_seri_no.ekipman_tipi,
                            cur_eq_ekipman_sahibi_seri_no.garanti_baslangic,
                            v_sahiplik_id);

               lg_ekipman_sahibi_kim_insert ('I',
                                             in_giren_kullanici,
                                             in_yeni_serial_number,
                                             in_account_number,
                                             in_outlet_location,
                                             cur_eq_ekipman_sahibi_seri_no.sales_agent_code,
                                             in_sebep_kodu,
                                             cur_eq_ekipman_sahibi_seri_no.ekipman_sahibi_tipi,
                                             in_aciklama,
                                             NULL,
                                             'H',
                                             cur_eq_ekipman_sahibi_seri_no.kampanya_kodu,
                                             cur_eq_ekipman_sahibi_seri_no.satis_bayi_kodu,
                                             cur_eq_ekipman_sahibi_seri_no.kampanya_ozellik_kodu,
                                             cur_eq_ekipman_sahibi_seri_no.kampanya_ozellik_degeri,
                                             cur_eq_ekipman_sahibi_seri_no.sahiplik_tipi,
                                             cur_eq_ekipman_sahibi_seri_no.ekipman_tipi,
                                             v_sahiplik_id,
                                             cur_eq_ekipman_sahibi_seri_no.garanti_baslangic,
                                             odurum
                                            );

               IF TRIM (odurum) != '0' THEN
                  odurum := 'Log islemi yapilamadi.' || odurum;
                  RETURN;
               END IF;
            END IF;

            -- eskisini iptal ediyor
            UPDATE eq_ekipman_sahibi_kim
               SET kayit_iptal          = 'E',
                   iptal_sebep_kodu     = in_iptal_sebep_kodu,
                   aciklama             = in_aciklama,
                   degistiren_kullanici = in_giren_kullanici,
                   degistirme_tarihi    = SYSDATE
             WHERE serial_number = in_serial_number;

            -- eskisinin iptal edilip, yenisinin girildigine dair iki log olmali.
            lg_ekipman_sahibi_kim_insert ('U',
                                          in_giren_kullanici,
                                          in_serial_number,
                                          cur_eq_ekipman_sahibi_seri_no.account_number,
                                          cur_eq_ekipman_sahibi_seri_no.outlet_location,
                                          cur_eq_ekipman_sahibi_seri_no.sales_agent_code,
                                          cur_eq_ekipman_sahibi_seri_no.sebep_kodu,
                                          cur_eq_ekipman_sahibi_seri_no.ekipman_sahibi_tipi,
                                          in_aciklama,
                                          in_iptal_sebep_kodu,
                                          'E',
                                          cur_eq_ekipman_sahibi_seri_no.kampanya_kodu,
                                          cur_eq_ekipman_sahibi_seri_no.satis_bayi_kodu,
                                          cur_eq_ekipman_sahibi_seri_no.kampanya_ozellik_kodu,
                                          cur_eq_ekipman_sahibi_seri_no.kampanya_ozellik_degeri,
                                          cur_eq_ekipman_sahibi_seri_no.sahiplik_tipi,
                                          cur_eq_ekipman_sahibi_seri_no.ekipman_tipi,
                                          cur_eq_ekipman_sahibi_seri_no.sahiplik_id,
                                          cur_eq_ekipman_sahibi_seri_no.garanti_baslangic,
                                          odurum
                                         );

            IF TRIM (odurum) != '0' THEN
               odurum := 'Log islemi yapilamadi.' || odurum;
               RETURN;
            END IF;

            UPDATE bt_bayi_kota_hp_svc
               SET account_number        = in_account_number,
                   outlet_location       = in_outlet_location,
                   aciklama              = in_aciklama,
                   degistiren_kullanici  = in_giren_kullanici,
                   degistirme_tarihi     = SYSDATE,
                   ekipman_serial_number = in_yeni_serial_number
             WHERE     ekipman_serial_number = in_serial_number
                   AND account_number = cur_eq_ekipman_sahibi_seri_no.account_number
                   AND outlet_location = cur_eq_ekipman_sahibi_seri_no.outlet_location;

            v_ittp_process_type := 1;
         ELSE -- EKD sebep kodu degilse,
            -- Yeni üye ve outlet için daha önce bir sahiplik yoksa, oraya tasinmasina izin verilir.
            UPDATE    eq_ekipman_sahibi_kim
                  SET account_number       = in_account_number,
                      outlet_location      = in_outlet_location,
                      degistiren_kullanici = in_giren_kullanici,
                      degistirme_tarihi    = SYSDATE,
                      sebep_kodu           = in_sebep_kodu,
                      aciklama             = in_aciklama
                WHERE serial_number = in_serial_number
            RETURNING sahiplik_id
                 INTO v_sahiplik_id;

            -- eskisinin iptal edilip, yenisinin girildigine dair iki log olmali.
            lg_ekipman_sahibi_kim_insert ('U',
                                          in_giren_kullanici,
                                          in_serial_number,
                                          cur_eq_ekipman_sahibi_seri_no.account_number,
                                          cur_eq_ekipman_sahibi_seri_no.outlet_location,
                                          cur_eq_ekipman_sahibi_seri_no.sales_agent_code,
                                          cur_eq_ekipman_sahibi_seri_no.sebep_kodu,
                                          cur_eq_ekipman_sahibi_seri_no.ekipman_sahibi_tipi,
                                          in_aciklama,
                                          in_iptal_sebep_kodu,
                                          'E',
                                          cur_eq_ekipman_sahibi_seri_no.kampanya_kodu,
                                          cur_eq_ekipman_sahibi_seri_no.satis_bayi_kodu,
                                          cur_eq_ekipman_sahibi_seri_no.kampanya_ozellik_kodu,
                                          cur_eq_ekipman_sahibi_seri_no.kampanya_ozellik_degeri,
                                          cur_eq_ekipman_sahibi_seri_no.sahiplik_tipi,
                                          cur_eq_ekipman_sahibi_seri_no.ekipman_tipi,
                                          cur_eq_ekipman_sahibi_seri_no.sahiplik_id,
                                          cur_eq_ekipman_sahibi_seri_no.garanti_baslangic,
                                          odurum
                                         );

            IF TRIM (odurum) != '0' THEN
               odurum := 'Log islemi yapilamadi.' || odurum;
               RETURN;
            END IF;

            -- eskisinin iptal edilip, yenisinin girildigine dair iki log olmali.
            lg_ekipman_sahibi_kim_insert ('U',
                                          in_giren_kullanici,
                                          in_serial_number,
                                          in_account_number,
                                          in_outlet_location,
                                          cur_eq_ekipman_sahibi_seri_no.sales_agent_code,
                                          in_sebep_kodu,
                                          cur_eq_ekipman_sahibi_seri_no.ekipman_sahibi_tipi,
                                          in_aciklama,
                                          NULL,
                                          'H',
                                          cur_eq_ekipman_sahibi_seri_no.kampanya_kodu,
                                          cur_eq_ekipman_sahibi_seri_no.satis_bayi_kodu,
                                          cur_eq_ekipman_sahibi_seri_no.kampanya_ozellik_kodu,
                                          cur_eq_ekipman_sahibi_seri_no.kampanya_ozellik_degeri,
                                          cur_eq_ekipman_sahibi_seri_no.sahiplik_tipi,
                                          cur_eq_ekipman_sahibi_seri_no.ekipman_tipi,
                                          cur_eq_ekipman_sahibi_seri_no.sahiplik_id,
                                          cur_eq_ekipman_sahibi_seri_no.garanti_baslangic,
                                          odurum
                                         );

            IF TRIM (odurum) != '0' THEN
               odurum := 'Log islemi yapilamadi.' || odurum;
               RETURN;
            END IF;

            UPDATE bt_bayi_kota_hp_svc
               SET account_number       = in_account_number,
                   outlet_location      = in_outlet_location,
                   aciklama             = in_aciklama,
                   degistiren_kullanici = in_giren_kullanici,
                   degistirme_tarihi    = SYSDATE
             WHERE     ekipman_serial_number = in_serial_number
                   AND account_number = cur_eq_ekipman_sahibi_seri_no.account_number
                   AND outlet_location = cur_eq_ekipman_sahibi_seri_no.outlet_location;

            v_ittp_process_type := 2;
         END IF;
      END LOOP;

      --
      --//===---BASLA ITTP Entegrasyon---===\\--

      --mcetinbag 20101009
      --Hanife Dilek 05/04/2011. Sahiplik tipine göre işlem yapılması
      --                         Sadece ekipman sahibi normal ve ekipman sahibi tipi üyenin ise..
      --Hanife Dilek 04/05/2011. Kartlar entegrasyona dahil edilmemeli
      OPEN cur_ekipman_tipi;

      FETCH cur_ekipman_tipi INTO v_converter_type;

      CLOSE cur_ekipman_tipi;

      IF rec_eq_ekipman_sahibi_seri_no.sahiplik_tipi = 0 AND rec_eq_ekipman_sahibi_seri_no.ekipman_sahibi_tipi = 1 AND NVL (v_converter_type, 'X') != 'SC' THEN
         billing_dbs_int.onl_order_ittp_pkg.integ_ekipman_sahip_transfer (i_process_type      => v_ittp_process_type,
                                                                          i_serial_number     => in_serial_number,
                                                                          i_new_serial_number => in_yeni_serial_number,
                                                                          i_account_number    => in_account_number,
                                                                          i_outlet_location   => in_outlet_location,
                                                                          i_sahiplik_id       => v_sahiplik_id,
                                                                          i_owner_sales_agent => v_ittp_owner_sales_agent,
                                                                          i_process_date      => SYSDATE,
                                                                          i_process_user      => in_giren_kullanici,
                                                                          o_result_type       => v_result_type,
                                                                          o_result_code       => v_result_code,
                                                                          o_result_message    => v_result_message
                                                                         );

         IF v_result_type <> 0 THEN
            odurum := 'ITTP Entegrasyon: ' || v_result_message;
            RETURN;
         END IF;
      END IF;
   --\\===---BITIR ITTP Entegrasyon---===//--
   --
   END;

   -- Sahiplik_id gerekti, aslinda seri no unique ama wiz_ar_trx için numeric bir alan gerekiyormus.
   -- Kayit takibi yine seri no üzerinden devam edecek.
   PROCEDURE eq_ekipman_sahibi_kim_ins_upd (in_serial_number         IN     eq_ekipman_sahibi_kim.serial_number%TYPE,
                                            in_account_number        IN     eq_ekipman_sahibi_kim.account_number%TYPE,
                                            in_outlet_location       IN     eq_ekipman_sahibi_kim.outlet_location%TYPE,
                                            in_ekipman_tipi          IN     eq_ekipman_sahibi_kim.ekipman_tipi%TYPE,
                                            in_sales_agent_code      IN     eq_ekipman_sahibi_kim.sales_agent_code%TYPE,
                                            in_sebep_kodu            IN     eq_ekipman_sahibi_kim.sebep_kodu%TYPE,
                                            in_ekipman_sahibi_tipi   IN     eq_ekipman_sahibi_kim.ekipman_sahibi_tipi%TYPE,
                                            in_aciklama              IN     eq_ekipman_sahibi_kim.aciklama%TYPE,
                                            in_iptal_sebep_kodu      IN     eq_ekipman_sahibi_kim.iptal_sebep_kodu%TYPE,
                                            in_kayit_iptal           IN     eq_ekipman_sahibi_kim.kayit_iptal%TYPE,
                                            in_giren_kullanici       IN     eq_ekipman_sahibi_kim.giren_kullanici%TYPE,
                                            in_ust_kampanya_kodu     IN     eq_ekipman_sahibi_kim.kampanya_kodu%TYPE,
                                            in_kampanya_kodu         IN     eq_ekipman_sahibi_kim.kampanya_kodu%TYPE,
                                            in_satis_bayii           IN     eq_ekipman_sahibi_kim.satis_bayi_kodu%TYPE,
                                            in_ekipman_tip_matrix_id IN     NUMBER,
                                            out_uyari                   OUT VARCHAR2,
                                            odurum                      OUT VARCHAR2,
                                            in_taahhut_kontrol       IN     CHAR := 'E'
                                           ) IS
      v_serial_number               eq_ekipman_sahibi_kim.serial_number%TYPE;
      v_account_number              eq_ekipman_sahibi_kim.account_number%TYPE;
      v_outlet_location             eq_ekipman_sahibi_kim.outlet_location%TYPE;
      v_sales_agent_code            eq_ekipman_sahibi_kim.sales_agent_code%TYPE;
      v_sebep_kodu                  eq_ekipman_sahibi_kim.sebep_kodu%TYPE;
      v_ekipman_sahibi_tipi         eq_ekipman_sahibi_kim.ekipman_sahibi_tipi%TYPE;
      v_aciklama                    eq_ekipman_sahibi_kim.aciklama%TYPE;
      v_iptal_sebep_kodu            eq_ekipman_sahibi_kim.iptal_sebep_kodu%TYPE;
      v_kayit_iptal                 eq_ekipman_sahibi_kim.kayit_iptal%TYPE;
      v_giren_kullanici             eq_ekipman_sahibi_kim.giren_kullanici%TYPE;
      v_ust_kampanya_kodu           eq_ekipman_sahibi_kim.kampanya_kodu%TYPE;
      v_kampanya_kodu               eq_ekipman_sahibi_kim.kampanya_kodu%TYPE;
      v_satis_bayii                 eq_ekipman_sahibi_kim.satis_bayi_kodu%TYPE;
      v_ekipman_tip_matrix_id       NUMBER;
      v_taahhut_kontrol             CHAR (1);
      v_ozellik_kodu                eq_ekipman_sahibi_kim.kampanya_ozellik_kodu%TYPE;
      v_ozellik_degeri              eq_ekipman_sahibi_kim.kampanya_ozellik_degeri%TYPE;
      v_ozellik_sorgu               VARCHAR2 (500);
      v_count                       NUMBER := 0;
      v_satilik                     VARCHAR2 (1);
      v_brand_ozellik_satilik       VARCHAR2 (1);
      v_uye_tipi                    VARCHAR2 (3);
      v_stb_tipi                    VARCHAR2 (2);
      v_franchise                   VARCHAR2 (3);
      v_uygun_il                    wiz_hp_description.city%TYPE;
      v_il                          co_il.kod%TYPE;
      v_ulke                        co_ulke.id%TYPE;
      vserviceaddressid             wiz_hp_description.service_address_id%TYPE;
      v_tekrar_satis                BOOLEAN;
      v_uye_sahiplik                eq_ekipman_sahibi_kim.serial_number%TYPE;
      v_sahipliktipi                eq_ekipman_sahibi_kim.sahiplik_tipi%TYPE;
      v_ekipman_tipi                eq_ekipman_sahibi_kim.ekipman_tipi%TYPE;
      v_sahiplik_id                 eq_ekipman_sahibi_kim.sahiplik_id%TYPE;
      v_garanti_baslangic           DATE;
      v_error_type                  NUMBER (1);
      out_taa_uyari                 VARCHAR2 (100);
      v_serial_sahiplik             VARCHAR2 (20);
      v_sahiplik_icin_cari_var      NUMBER (1);
      --
      v_ittp_integ_open             NUMBER (1);
      v_ittp_payment_method         NUMBER (1);
      v_ittp_service_code           VARCHAR2 (50);
      v_ittp_sahiplik_yap           NUMBER (1);
      v_ittp_ekipman_sahibi_tipi    NUMBER (1);
      v_ittp_sahiplik_sebep_kodu    VARCHAR2 (3);
      v_ittp_kayit_iptal_et         NUMBER (1);
      v_result_type                 NUMBER;
      v_result_code                 VARCHAR2 (20);
      v_result_message              VARCHAR2 (512);
      v_ittp_campaign_sales_channel NUMBER;
      --  v_ekipman_tipi_iptal   number;
      v_kitle_sonuc                 VARCHAR2 (255); --MKECECI

      --v_ittp_order_int_open         NUMBER; -- ittp entegrasyon

      CURSOR eq_ekipman_sahibi_kim_cur  IS
         SELECT     *
               FROM eq_ekipman_sahibi_kim
              WHERE serial_number = v_serial_number
         FOR UPDATE OF degistirme_tarihi NOWAIT;

      -- var olan gecici sahiplikleri bulan cursor
      -- bunların iptal edilmesi gerekmekte
      --15.01.2012
      /*         CURSOR eq_ekipman_sahibi_kim_cur_gec
       IS
          SELECT        *
                   FROM eq_ekipman_sahibi_kim
                  WHERE account_number = v_account_number
                  and outlet_location=v_outlet_location
                  and kayit_iptal='H'
                  and serial_number<>v_serial_number
                  and ekipman_tipi=v_ekipman_tipi_iptal;
                  */

      eq_ekipman_sahibi_kim_rec     eq_ekipman_sahibi_kim_cur%ROWTYPE;
      --eq_ekipman_sahibi_kim_gec_rec  eq_ekipman_sahibi_kim_cur_gec%ROWTYPE;
      v_converter_type              VARCHAR2 (2);
      v_camp_charge_type            NUMBER;
      v_effective_date              DATE;
      v_temp_account_number         NUMBER;
      v_temp_outlet_location        VARCHAR2 (3);

      CURSOR cur_ekipman_tipi  IS
         SELECT converter_type
           FROM wiz_equip
          WHERE serial_number = v_serial_number;

      CURSOR cur_camp_charge_type (i_campaign_code IN VARCHAR2) IS
         SELECT charge_type
           FROM pr_ekipman_taksit_plan
          WHERE campaign_code = i_campaign_code AND charge_type = 3;
   BEGIN
      --  v_ekipman_tipi_iptal:= TRIM (in_ekipman_tipi);

      odurum                  := '0';
      v_tekrar_satis          := FALSE;
      v_serial_number         := TRIM (in_serial_number);
      v_account_number        := TRIM (in_account_number);
      v_outlet_location       := TRIM (in_outlet_location);
      v_ekipman_tipi          := TRIM (in_ekipman_tipi);
      v_sales_agent_code      := TRIM (in_sales_agent_code);
      v_sebep_kodu            := TRIM (in_sebep_kodu);
      v_ekipman_sahibi_tipi   := TRIM (in_ekipman_sahibi_tipi);
      v_aciklama              := TRIM (in_aciklama);
      v_iptal_sebep_kodu      := TRIM (in_iptal_sebep_kodu);
      v_kayit_iptal           := TRIM (in_kayit_iptal);
      v_giren_kullanici       := TRIM (in_giren_kullanici);
      v_ust_kampanya_kodu     := TRIM (in_ust_kampanya_kodu);
      v_kampanya_kodu         := TRIM (in_kampanya_kodu);
      v_satis_bayii           := TRIM (in_satis_bayii);
      v_ekipman_tip_matrix_id := TRIM (in_ekipman_tip_matrix_id);
      v_taahhut_kontrol       := TRIM (in_taahhut_kontrol);

      IF TRIM (v_serial_number) IS NULL THEN
         odurum := 'Ekipman bilgisi bos.';
         RETURN;
      END IF;

      --<begin> - MKECECI - transfer olan üyelere sahiplik yapılması engellendi
      IF v_account_number IS NOT NULL AND v_account_number > 0 AND v_outlet_location IS NOT NULL AND v_serial_number IS NOT NULL AND v_kayit_iptal = 'H' THEN
         SELECT COUNT (1)
           INTO v_count
           FROM mb_abone_statu
          WHERE account_number = v_account_number AND outlet_location = v_outlet_location AND statu = 'T';

         IF v_count > 0 THEN
            odurum := v_account_number || '-' || v_outlet_location || ' üyeliği başka bir üyeliğe transfer edilmiş!!';
            RETURN;
         END IF;

         BEGIN
            SELECT account_number, outlet_location
              INTO v_temp_account_number, v_temp_outlet_location
              FROM wiz_equip
             WHERE serial_number = v_serial_number;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT account_number, outlet_location
                    INTO v_temp_account_number, v_temp_outlet_location
                    FROM eq_ekipman
                   WHERE serial_number = v_serial_number;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_temp_account_number := 0;
               END;
         END;

         IF (v_account_number <> v_temp_account_number OR v_outlet_location <> v_temp_outlet_location) AND v_temp_account_number <> 0 THEN
            odurum := 'Bu ekipman ' || v_temp_account_number || '-' || v_outlet_location || ' üyeliğinin üzerindedir';
            RETURN;
         END IF;
      END IF;

      --</end>

      -- ozgur arslan 15.01.2012
      --      begin
      --            select decode(converter_type,'SC',246,'ST',247,converter_type) into v_ekipman_tipi_iptal  from wiz_equip where serial_number=v_serial_number;
      --      exception when no_data_found then
      --            select ekipman_tipi into v_ekipman_tipi_iptal  from eq_ekipman where serial_number=v_serial_number;
      --      end;

      IF TRIM (v_ekipman_sahibi_tipi) IS NULL THEN
         odurum := 'Ekipman sahibi tipi bilgisi bos.';
         RETURN;
      END IF;

      IF TRIM (v_sebep_kodu) IS NULL THEN
         odurum := 'Sebep kodu bilgisi bos.';
         RETURN;
      END IF;

      -- ZS Outlet kampanyalarinda kutu, geçici olarak aboneye verilebilecek.
      -- Bunun için kampanyalara 41 özelligi eklendi.
      -- v_SahiplikTipi = 0 ise normal, 1 ise geçici sahiplik
      v_sahipliktipi          := servis_util_pack.urun_ozellik_var_mi ('1', v_kampanya_kodu, 41);

      OPEN eq_ekipman_sahibi_kim_cur;

      FETCH eq_ekipman_sahibi_kim_cur INTO eq_ekipman_sahibi_kim_rec;

      --   OPEN eq_ekipman_sahibi_kim_cur_gec;

      --  FETCH eq_ekipman_sahibi_kim_cur_gec
      --   INTO eq_ekipman_sahibi_kim_gec_rec;
      -- Daha önceden satilmis ve iptal edilmis bir kutunun tekrar satisi veya
      -- Bayiye satilmis bir kutunun üyeye satisi
      IF eq_ekipman_sahibi_kim_cur%FOUND THEN
         IF    (v_kayit_iptal = 'H' AND eq_ekipman_sahibi_kim_rec.kayit_iptal = 'E')
            OR (eq_ekipman_sahibi_kim_rec.ekipman_sahibi_tipi = 2 AND v_account_number IS NOT NULL) THEN
            v_tekrar_satis := TRUE;
         END IF;
      END IF;

      /*
      WHILE eq_ekipman_sahibi_kim_cur_gec%FOUND LOOP
         IF    (eq_ekipman_sahibi_kim_gec_rec.kayit_iptal = 'H' and eq_ekipman_sahibi_kim_gec_rec.ekipman_sahibi_tipi = 1 AND v_account_number IS NOT NULL)
         THEN
             UPDATE eq_ekipman_sahibi_kim
               SET
                   aciklama = v_aciklama,
                   sebep_kodu = NVL (v_sebep_kodu, eq_ekipman_sahibi_kim_gec_rec.sebep_kodu),
                   iptal_sebep_kodu = 'EKD',
                   kayit_iptal ='E',
                   degistiren_kullanici = v_giren_kullanici,
                   degistirme_tarihi = SYSDATE
            WHERE  serial_number = eq_ekipman_sahibi_kim_gec_rec.serial_number AND sahiplik_id = eq_ekipman_sahibi_kim_gec_rec.sahiplik_id;
         END IF;
         FETCH eq_ekipman_sahibi_kim_cur_gec
       INTO eq_ekipman_sahibi_kim_gec_rec;
      END LOOP;
      */

      IF eq_ekipman_sahibi_kim_cur%NOTFOUND OR v_tekrar_satis THEN
         IF TRIM (v_ekipman_sahibi_tipi) = 1 THEN
            IF TRIM (v_account_number) IS NULL THEN
               odurum := 'Üye bilgisi bos.';

               IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                  CLOSE eq_ekipman_sahibi_kim_cur;
               END IF;

               RETURN;
            END IF;

            SELECT MIN (customer_type), MIN (service_address_id), MIN (hp_cluster), MIN (franchise_code)
              INTO v_uye_tipi, vserviceaddressid, v_stb_tipi, v_franchise
              FROM wiz_customer_hp_life
             WHERE account_number = v_account_number;

            IF v_uye_tipi IS NULL THEN
               odurum := 'Üye no bilgisi hatali.';

               IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                  CLOSE eq_ekipman_sahibi_kim_cur;
               END IF;

               RETURN;
            END IF;

            -- Üyenin bu outletinde başka sahiplik varsa, ve bu sahiplik denk model kutu ise , ikincisine izin verilmez.
            -- Aksi takdirde bir outlette ikinci sahiplik olabilir.
            DECLARE
               out_result  VARCHAR2 (1);
               oproc_name  VARCHAR2 (500);
               oerror_type NUMBER (1);
               oerror_code VARCHAR2 (10);
               oerror_text VARCHAR2 (500);
            BEGIN
               v_serial_sahiplik := ekipman_sahibi (v_account_number, v_outlet_location, v_ekipman_tipi); -- 247

               IF v_serial_sahiplik IS NOT NULL THEN
                  ekipman_transfer_edilebilir_mi (v_serial_sahiplik,
                                                  v_ekipman_tip_matrix_id,
                                                  2,
                                                  out_result,
                                                  odurum,
                                                  oproc_name,
                                                  oerror_type,
                                                  oerror_code,
                                                  oerror_text
                                                 );

                  IF odurum <> '0' THEN
                     IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                        CLOSE eq_ekipman_sahibi_kim_cur;
                     END IF;

                     RETURN;
                  END IF;

                  -- bu if aslinda yeni ekipman = eski ekipman mi kontrolu yapar
                  -- 1=matrix ayni transfer edilebilir,
                  -- 2=52 ozelligi var, isleme devam et ama transfer etme,
                  -- 3=pr_urun_ozellik_tanim da kayit var transfer edilebilir
                  -- 4=ekipman ayni degil, isleme devam etme (ELSE e düs)
                  IF out_result = 1 OR out_result = 3 THEN
                     odurum := 'Üye bu outlette denk bir model kutuya sahiptir. !';

                     IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                        CLOSE eq_ekipman_sahibi_kim_cur;
                     END IF;

                     RETURN;
                  END IF;
               END IF;
            END;

            IF v_kayit_iptal = 'H' THEN
               IF v_kampanya_kodu IS NULL THEN
                  odurum := 'Satilik ekipmanlar için kampanya kodu girilmelidir.';

                  IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                     CLOSE eq_ekipman_sahibi_kim_cur;
                  END IF;

                  RETURN;
               ELSE
                  -- Kampanya yetki_kategori özelligi ile yetkilendirildiyse;
                  DECLARE
                     v_yetki_kategorisi VARCHAR2 (5);
                  BEGIN
                     servis_util_pack.get_urun_islem_yetki_tanim (v_account_number,
                                                                  NULL,
                                                                  v_outlet_location,
                                                                  NULL,
                                                                  v_kampanya_kodu,
                                                                  NULL,
                                                                  NULL,
                                                                  NULL,
                                                                  147,
                                                                  1,
                                                                  v_giren_kullanici,
                                                                  v_yetki_kategorisi,
                                                                  odurum,
                                                                  1
                                                                 );

                     IF odurum <> '0' THEN
                        odurum := odurum;

                        IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                           CLOSE eq_ekipman_sahibi_kim_cur;
                        END IF;

                        RETURN;
                     END IF;

                     IF v_yetki_kategorisi IS NOT NULL THEN
                        IF yetki_pack.yetkisi_varmi (v_giren_kullanici, 'ISLEM_URUN_YETKI_KATEGORI_' || v_yetki_kategorisi) = 0 THEN
                           odurum := 'Bu kampanya için yetkiniz yok';

                           IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                              CLOSE eq_ekipman_sahibi_kim_cur;
                           END IF;

                           RETURN;
                        END IF;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        odurum := 'Kampanya yetki kontrolü basarisiz :' || SQLERRM;

                        IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                           CLOSE eq_ekipman_sahibi_kim_cur;
                        END IF;

                        RETURN;
                  END;

                  -- Kampanya il kisiti var mi ? Temmuz 2007
                  -- Önce abonenin ili bulunur

                  --Asagidaki sorguda ulke degeri olmadigindan ayni ile sahip
                  --iki farkli ulkede sorun yasaniyordu (mcetinbag 20080604)
                  SELECT a.id, NVL (b.kod, '-1')
                    INTO v_ulke, v_il
                    FROM (SELECT u.id, hp.city
                            FROM wiz_hp_description hp,
                                 co_ulke u
                           WHERE hp.service_address_id = vserviceaddressid AND hp.ulke = u.ad) a,
                         co_il b
                   WHERE a.id = b.ulke_id(+) AND a.city = b.ad(+);

                  SELECT MIN (DECODE (ulke, v_ulke, DECODE (NVL (il, v_il), v_il, 0, 1), 1)) uygun_il
                    INTO v_uygun_il
                    FROM icr_dp_servis_default_bayi_det
                   WHERE     (baslangic_tarihi IS NULL OR baslangic_tarihi <= SYSDATE)
                         AND (bitis_tarihi IS NULL OR bitis_tarihi > SYSDATE)
                         AND kampanya = v_kampanya_kodu
                         AND ulke IS NOT NULL;

                  IF NVL (v_uygun_il, 0) = 1 THEN
                     odurum := 'Kampanyada il kisiti vardir, tanimli illerden biri için satis yapilabilir.';

                     IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                        CLOSE eq_ekipman_sahibi_kim_cur;
                     END IF;

                     RETURN;
                  END IF;

                  -- Kampanya kodu var ise, ve bu kampanyanin bir kitle tanimi var ise,
                  -- abone ve ekipmanin bu kampanya kitlesi içinde olup olmadigi kontrol edilmelidir.
                  v_kitle_sonuc      := kitle_pack.kitleye_uygun_mu (v_ust_kampanya_kodu,
                                                                     v_kampanya_kodu,
                                                                     NULL,
                                                                     NULL,
                                                                     v_account_number,
                                                                     v_outlet_location,
                                                                     NULL,
                                                                     v_ekipman_tip_matrix_id,
                                                                     v_serial_number,
                                                                     v_uye_tipi,
                                                                     v_stb_tipi,
                                                                     v_franchise,
                                                                     SYSDATE,
                                                                     v_giren_kullanici
                                                                    );

                  IF v_kitle_sonuc <> '0' THEN
                     --Kitleye neden uymadığının açıklaması döndürülüyor.MKECECI
                     --odurum := 'Satis kampanyasi, bu abone veya ekipman için uygun degildir !';
                     odurum := v_kitle_sonuc;

                     IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                        CLOSE eq_ekipman_sahibi_kim_cur;
                     END IF;

                     RETURN;
                  END IF;

                  -- Bayiden satis, depo, bayi kota islemleri ve kontrolleri
                  DECLARE
                     v_bayiden_satis          VARCHAR2 (1) := 'H';
                     v_bayi_kota_id           NUMBER (10);
                     v_kota_svc_id            NUMBER (10);
                     v_campaign_sales_channel NUMBER (5);
                     v_uye_tip_ticari_konut   VARCHAR2 (6);
                     v_uye_kategori           VARCHAR2 (30);
                     v_ekipmandeposbt         VARCHAR2 (1);
                     v_ekipmandepoyetki       NUMBER;
                     v_equip_location_code    VARCHAR2 (10);
                  BEGIN
                     -- Modül kontrolü de eklendi. 29.03.2011
                     -- IF v_ekipman_tip_matrix_id <> 25
                     -- THEN
                     v_ekipmandeposbt              := dbs_sabit ('BAYI_TS_KENDI_DEPOSUNDAN_EKIPMAN_SATMALI');
                     v_ekipmandepoyetki            := yetki_pack.yetkisi_varmi (v_giren_kullanici, 'DEPO_EKIPMAN_SATIS_UYUMU_KONTROLU_ATLA');

                     IF v_ekipmandeposbt = 'E' AND v_ekipmandepoyetki = 0 THEN
                        BEGIN
                           SELECT TRIM (equip_location_code)
                             INTO v_equip_location_code
                             FROM wiz_equip we
                            WHERE we.serial_number = v_serial_number;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              SELECT TRIM (equip_location_code)
                                INTO v_equip_location_code
                                FROM eq_ekipman we
                               WHERE we.serial_number = v_serial_number --AND ekipman_tipi = 248;
                                                                       AND ekipman_tipi IN (248, 300, 301, 302);
                        END;

                        IF v_equip_location_code IS NOT NULL THEN
                           SELECT COUNT (1)
                             INTO v_count
                             FROM wiz_equip_location_codes wel
                            WHERE     wel.equip_location_code = v_equip_location_code
                                  AND (wel.ust_depo_kod = 'ZINCIR MAGAZA' OR (wel.employee_code = v_satis_bayii OR wel.employee_code IS NULL));

                           IF v_count = 0 THEN
                              odurum := 'BU EKIPMAN BU DEPODAN BU BAYI/TS ÜZERINDEN UYEYE SATILAMAZ.';

                              IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                                 CLOSE eq_ekipman_sahibi_kim_cur;
                              END IF;

                              RETURN;
                           END IF;
                        END IF;
                     END IF;

                     -- END IF;

                     -- Zaten bir kayit vardir.

                     /**** Falamur  14032014 */
                     --                     v_ittp_order_int_open :=
                     --                        billing_dbs_int.exclude_control_pkg.is_integration_active (
                     --                           'ITTP_ORDER_INT');

                     --                     IF v_ittp_order_int_open = 0
                     --                     THEN

                     SELECT NVL (MIN (campaign_sales_channel), 0)
                       INTO v_campaign_sales_channel
                       FROM wiz_campaign_codes
                      WHERE campaign_code = v_kampanya_kodu;

                     --                     ELSIF v_ittp_order_int_open = 1
                     --                     THEN
                     --                        SELECT NVL (MIN (kmp.campaign_sales_channel), 0)
                     --                          INTO v_campaign_sales_channel
                     --                          FROM dt_dbs_int_dba.vv_ittp_kampanyalar kmp
                     --                         WHERE campaign_code = v_kampanya_kodu;
                     --                     --GRANT SELECT ON DT_DBS_INT_DBA.VV_ITTP_KAMPANYALAR TO DBS_DBA;
                     --                     --                        v_campaign_sales_channel := DT_DBS_INT_API.OFFER_PKG.GET_SALES_CHANNEL_ID(v_kampanya_kodu);
                     --                     --GRANT EXECUTE ON DT_DBS_INT_API.OFFER_PKG TO DBS_DBA;
                     --                     END IF;

                     v_ittp_campaign_sales_channel := v_campaign_sales_channel;

                     -- Bayiden satis ise, bayi kodu zorunludur.
                     IF v_satis_bayii IS NULL THEN
                        IF v_campaign_sales_channel = 4 OR v_campaign_sales_channel = 2 THEN
                           odurum := 'Kampanya bayiden satis kampanyasidir, BAYI kodu zorunludur';

                           IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                              CLOSE eq_ekipman_sahibi_kim_cur;
                           END IF;

                           RETURN;
                        END IF;
                     END IF;

                     -- Bayiden satisli ise hangi bayi ile tanimlanmis ?
                     IF v_campaign_sales_channel = 4 THEN
                        SELECT MIN (DECODE (bayi_kodu, v_satis_bayii, DECODE (NVL (ulke, v_ulke), v_ulke, DECODE (NVL (il, v_il), v_il, 0, 1), 1), 1))
                                  uygun_bayi
                          INTO v_count
                          FROM icr_dp_servis_default_bayi_det
                         WHERE     (baslangic_tarihi IS NULL OR baslangic_tarihi <= SYSDATE)
                               AND (bitis_tarihi IS NULL OR bitis_tarihi > SYSDATE)
                               AND kampanya = v_kampanya_kodu
                               AND bayi_kodu IS NOT NULL;

                        IF NVL (v_count, 0) = 1 THEN
                           odurum := 'Sadece bu kampanya için tanimlanmis bayiler ile satis yapilabilir !';

                           IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                              CLOSE eq_ekipman_sahibi_kim_cur;
                           END IF;

                           RETURN;
                        END IF;
                     ELSIF v_campaign_sales_channel = 2 THEN
                        SELECT aciklama
                          INTO v_uye_tip_ticari_konut
                          FROM vv_uye_tipi
                         WHERE customer_type = v_uye_tipi;

                        IF TRIM (v_uye_tip_ticari_konut) = 'TİCARİ' THEN
                           SELECT aciklama
                             INTO v_uye_kategori
                             FROM pr_abone_ozellik a,
                                  mb_abone_ozellik b
                            WHERE a.kod = b.abone_ozellik_kodu AND b.account_number = v_account_number AND a.kod_grubu = 1;
                        ELSE
                           v_uye_kategori := NULL;
                        END IF;

                        bayi_detay_pack.tanimli_kota_var_mi (v_account_number,
                                                             v_kampanya_kodu,
                                                             NULL,
                                                             v_uye_kategori,
                                                             NULL,
                                                             NULL,
                                                             v_satis_bayii,
                                                             v_bayiden_satis,
                                                             v_bayi_kota_id,
                                                             odurum
                                                            );

                        IF odurum <> '0' THEN
                           odurum := odurum;

                           IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                              CLOSE eq_ekipman_sahibi_kim_cur;
                           END IF;

                           RETURN;
                        END IF;

                        bayi_detay_pack.bt_bayi_kota_hp_svc_ins_upd_ek (v_account_number,
                                                                        v_outlet_location,
                                                                        v_bayi_kota_id,
                                                                        v_kampanya_kodu,
                                                                        v_satis_bayii,
                                                                        'H',
                                                                        v_uye_kategori,
                                                                        v_sebep_kodu,
                                                                        'Ekipman satisi',
                                                                        v_serial_number,
                                                                        v_giren_kullanici,
                                                                        v_kota_svc_id,
                                                                        odurum
                                                                       );

                        IF odurum <> '0' THEN
                           IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                              CLOSE eq_ekipman_sahibi_kim_cur;
                           END IF;

                           RETURN;
                        END IF;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        odurum := 'eq_ekipman_sahibi_kim_ins_upd hata::' || SUBSTR (SQLERRM, 1, 50);

                        IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                           CLOSE eq_ekipman_sahibi_kim_cur;
                        END IF;

                        RETURN;
                  END;

                  BEGIN
                     -- Kampanyanin özelligi varsa, degerini satis tablosunda sakla.
                     -- Bir tane özellik oldugu varsayilmistir.
                     v_ozellik_kodu   := NULL;
                     v_ozellik_degeri := NULL;

                     SELECT ozellik_kodu, ozellik_sorgu
                       INTO v_ozellik_kodu, v_ozellik_sorgu
                       FROM pr_urun_ozellik_sorgu
                      WHERE ozellik_kodu IN (SELECT ozellik_kodu
                                               FROM pr_urun_ozellik_tanim
                                              WHERE urun_tipi = 1 AND urun_kodu = v_kampanya_kodu);

                     EXECUTE IMMEDIATE v_ozellik_sorgu INTO v_ozellik_degeri USING v_account_number;
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_ozellik_degeri := NULL;
                  END;
               END IF; -- kampanya varsa;
            END IF;
         ELSIF TRIM (v_ekipman_sahibi_tipi) = 2 THEN
            IF TRIM (v_sales_agent_code) IS NULL THEN
               odurum := 'Teknik servis bilgisi bos.';

               IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                  CLOSE eq_ekipman_sahibi_kim_cur;
               END IF;

               RETURN;
            END IF;

            SELECT COUNT (1)
              INTO v_count
              FROM bt_bayi_teknik_servis
             WHERE sales_agent_code = v_sales_agent_code;

            IF v_count = 0 THEN
               odurum := 'Teknik servis bilgisi hatali.';

               IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                  CLOSE eq_ekipman_sahibi_kim_cur;
               END IF;

               RETURN;
            END IF;
         END IF;

         -- Sahiplik üyeden üyeye ise garanti tarihi tasinir,
         -- Bayiden üyeye geçiyorsa garanti baslangiç tarihi, satis günüdür.
         IF     eq_ekipman_sahibi_kim_rec.ekipman_sahibi_tipi = 1
            AND v_ekipman_sahibi_tipi = 1
            AND eq_ekipman_sahibi_kim_rec.kayit_iptal = 'H'
            AND v_kayit_iptal = 'H' THEN
            v_garanti_baslangic := eq_ekipman_sahibi_kim_rec.garanti_baslangic;
         ELSE
            v_garanti_baslangic := SYSDATE;
         END IF;

         IF v_tekrar_satis THEN
            v_sahiplik_id := eq_ekipman_sahibi_kim_rec.sahiplik_id;

            UPDATE eq_ekipman_sahibi_kim
               SET account_number          = v_account_number,
                   outlet_location         = v_outlet_location,
                   sales_agent_code        = v_sales_agent_code,
                   ekipman_sahibi_tipi     = NVL (v_ekipman_sahibi_tipi, eq_ekipman_sahibi_kim_rec.ekipman_sahibi_tipi),
                   aciklama                = v_aciklama,
                   sebep_kodu              = NVL (v_sebep_kodu, eq_ekipman_sahibi_kim_rec.sebep_kodu),
                   iptal_sebep_kodu        = v_iptal_sebep_kodu,
                   kayit_iptal             = v_kayit_iptal,
                   kampanya_kodu           = v_kampanya_kodu,
                   sahiplik_tipi           = v_sahipliktipi,
                   ekipman_tipi            = v_ekipman_tipi,
                   satis_bayi_kodu         = v_satis_bayii,
                   kampanya_ozellik_kodu   = v_ozellik_kodu,
                   kampanya_ozellik_degeri = v_ozellik_degeri,
                   degistiren_kullanici    = v_giren_kullanici,
                   degistirme_tarihi       = SYSDATE,
                   garanti_baslangic       = v_garanti_baslangic
             --Hanife Dilek 27/05/2011. RETURNING kullanımı için CURRENT OF kullanımı kaldırıldı.
             WHERE serial_number = eq_ekipman_sahibi_kim_rec.serial_number AND sahiplik_id = eq_ekipman_sahibi_kim_rec.sahiplik_id;

            lg_ekipman_sahibi_kim_insert ('U',
                                          v_giren_kullanici,
                                          v_serial_number,
                                          v_account_number,
                                          v_outlet_location,
                                          v_sales_agent_code,
                                          v_sebep_kodu,
                                          v_ekipman_sahibi_tipi,
                                          v_aciklama,
                                          v_iptal_sebep_kodu,
                                          v_kayit_iptal,
                                          v_kampanya_kodu,
                                          v_satis_bayii,
                                          v_ozellik_kodu,
                                          v_ozellik_degeri,
                                          v_sahipliktipi,
                                          v_ekipman_tipi,
                                          v_sahiplik_id,
                                          v_garanti_baslangic,
                                          odurum
                                         );

            IF TRIM (odurum) != '0' THEN
               odurum := 'Log islemi yapilamadi.' || odurum;

               IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                  CLOSE eq_ekipman_sahibi_kim_cur;
               END IF;

               RETURN;
            END IF;
         ELSE
            SELECT eq_ekipman_sahibi_seq.NEXTVAL INTO v_sahiplik_id FROM DUAL;

            INSERT
              INTO eq_ekipman_sahibi_kim (sahiplik_id,
                                          serial_number,
                                          account_number,
                                          outlet_location,
                                          ekipman_tipi,
                                          sales_agent_code,
                                          sebep_kodu,
                                          ekipman_sahibi_tipi,
                                          aciklama,
                                          iptal_sebep_kodu,
                                          kayit_iptal,
                                          kampanya_kodu,
                                          satis_bayi_kodu,
                                          sahiplik_tipi,
                                          kampanya_ozellik_kodu,
                                          kampanya_ozellik_degeri,
                                          giren_kullanici,
                                          giris_tarihi,
                                          degistiren_kullanici,
                                          degistirme_tarihi,
                                          garanti_baslangic
                                         )
               VALUES (
                         v_sahiplik_id,
                         v_serial_number,
                         v_account_number,
                         v_outlet_location,
                         v_ekipman_tipi,
                         v_sales_agent_code,
                         v_sebep_kodu,
                         v_ekipman_sahibi_tipi,
                         v_aciklama,
                         v_iptal_sebep_kodu,
                         v_kayit_iptal,
                         v_kampanya_kodu,
                         v_satis_bayii,
                         v_sahipliktipi,
                         v_ozellik_kodu,
                         v_ozellik_degeri,
                         v_giren_kullanici,
                         SYSDATE,
                         v_giren_kullanici,
                         SYSDATE,
                         v_garanti_baslangic);

            lg_ekipman_sahibi_kim_insert ('I',
                                          v_giren_kullanici,
                                          v_serial_number,
                                          v_account_number,
                                          v_outlet_location,
                                          v_sales_agent_code,
                                          v_sebep_kodu,
                                          v_ekipman_sahibi_tipi,
                                          v_aciklama,
                                          v_iptal_sebep_kodu,
                                          v_kayit_iptal,
                                          v_kampanya_kodu,
                                          v_satis_bayii,
                                          v_ozellik_kodu,
                                          v_ozellik_degeri,
                                          v_sahipliktipi,
                                          v_ekipman_tipi,
                                          v_sahiplik_id,
                                          v_garanti_baslangic,
                                          odurum
                                         );

            IF TRIM (odurum) != '0' THEN
               odurum := 'Log islemi yapilamadi.' || odurum;

               IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                  CLOSE eq_ekipman_sahibi_kim_cur;
               END IF;

               RETURN;
            END IF;
         END IF;

         fatura.taa_taahhut_pack.abone_taahhut_kontrol (v_account_number, v_outlet_location, 'ES', v_serial_number, v_giren_kullanici, out_uyari, odurum);

         IF odurum <> '0' THEN
            odurum := 'FATURA.TAA_TAAHHUT_PACK.ABONE_TAAHHUT_KONTROL: TAAHHÜT ISLEMLERINDE HATA OLUSTU: ' || odurum;

            IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
               CLOSE eq_ekipman_sahibi_kim_cur;
            END IF;

            RETURN;
         END IF;

         -- Kredi karti veya faturali her satis için borçlandirma kaydi açilir.
         -- Ekranda KK tahsilati yapilirsa, alacak da olusur, dengeler, veya faturaya çikildiginda ödenirse, o sirada alacak kaydi olusur.

         /**** Falamur  14032014 */
         --         v_ittp_order_int_open :=
         --            billing_dbs_int.exclude_control_pkg.is_integration_active (
         --               'ITTP_ORDER_INT');
         --
         --         IF v_ittp_order_int_open = 0
         --         THEN
         SELECT COUNT (1)
           INTO v_count
           FROM prod_dba.wiz_campaign_codes
          WHERE campaign_code = v_kampanya_kodu AND campaign_sales_channel IN (2, 4);

         --         ELSIF v_ittp_order_int_open = 1
         --         THEN
         --            SELECT COUNT (1)
         --              INTO v_count
         --              FROM dt_dbs_int_dba.vv_ittp_kampanyalar kmp
         --             WHERE     campaign_code = v_kampanya_kodu
         --                   AND campaign_sales_channel IN (2, 4);
         --         --               v_count := DT_DBS_INT_API.OFFER_PKG.GET_SALES_CHANNEL_ID(v_kampanya_kodu);
         --         END IF;

         SELECT COUNT (1)
           INTO v_sahiplik_icin_cari_var
           FROM TABLE (split_table_fnc (dbs_sabit ('CARI_KAYITSIZ_KUTU_SAHIPLENDIREN_KAMPANYALAR')))
          WHERE COLUMN_VALUE = v_kampanya_kodu;

         IF v_account_number IS NOT NULL --uye numarasi bos degil ise
                                        AND TRIM (v_ekipman_sahibi_tipi) = 1 --abone uzerine sahiplik yapiliyorsa
                                                                            AND (v_sahipliktipi <> 1) --gercek sahiplik yapiliyorsa
                                                                                                     AND v_count = 0 --bayi kotali veya bayiden satis degilse
                                                                                                                    AND v_sahiplik_icin_cari_var = 0 --cari kayit olusturulan kampanya
                                                                                                                                                     --Gecici sahiplik olusturulurken cari kayit atilmasin dendi. 2008-07-03 tarihli faturalamada hata olustu
                                                                                                                                                     --Ayrica bayiden satisli kampanyalarda da girmemesi gerekiyor. Ancak bayi tahsilatlarini
                                                                                                                                                     --iceri aldigimizda bu kontrolu kaldirmaliyiz. Hatali kampanya tanimlarindan (bayi satisli ama uye fiyati girilmis)
                                                                                                                                                     --dolayi bu if e sales_channel kontrolunu de ekledik.. mcetinbag
                                                                                                                                                     --Son olarak MANTIS gecisi ile birlikte ekipman sahipligi yapilirken CARI_KAYITSIZ_KUTU_SAHIPLENDIREN_KAMPANYALAR
                                                                                                                                                     --disinda bir kampanya ile sahiplendiriliyorsa cari kayit islenmelidir dendi. Yukaridaki if e bu da eklendi.
          THEN
            cari_islemler_pack.ekipman_borclandir (v_account_number,
                                                   v_outlet_location,
                                                   v_serial_number,
                                                   v_kampanya_kodu,
                                                   v_satis_bayii,
                                                   v_sahiplik_id,
                                                   v_giren_kullanici,
                                                   odurum
                                                  );

            IF TRIM (odurum) != '0' THEN
               odurum := 'Borçlandirma olusturulamadi :' || odurum;

               IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                  CLOSE eq_ekipman_sahibi_kim_cur;
               END IF;

               RETURN;
            END IF;
         END IF;

         v_ittp_sahiplik_yap        := 1;
         v_ittp_sahiplik_sebep_kodu := NVL (v_sebep_kodu, eq_ekipman_sahibi_kim_rec.sebep_kodu);
         v_ittp_ekipman_sahibi_tipi := NVL (v_ekipman_sahibi_tipi, eq_ekipman_sahibi_kim_rec.ekipman_sahibi_tipi);

         --Bayiden uyeye veriliyorsa Bayi Involvement Role unu dusur
         IF eq_ekipman_sahibi_kim_rec.ekipman_sahibi_tipi = 2 AND v_account_number IS NOT NULL THEN
            v_ittp_kayit_iptal_et := 1;
         END IF;
      ELSE
         IF v_kayit_iptal = 'E' THEN
            v_sahiplik_id              := eq_ekipman_sahibi_kim_rec.sahiplik_id;
            v_ittp_ekipman_sahibi_tipi := v_ekipman_sahibi_tipi; -- Hatalı kod düzeltilmek için yazıldı

            SELECT MIN (franchise_code)
              INTO v_franchise
              FROM wiz_customer_hp_life
             WHERE account_number = v_account_number;

            UPDATE eq_ekipman_sahibi_kim
               SET kayit_iptal          = v_kayit_iptal,
                   aciklama             = v_aciklama,
                   iptal_sebep_kodu     = v_iptal_sebep_kodu,
                   degistiren_kullanici = v_giren_kullanici,
                   degistirme_tarihi    = SYSDATE
             --Hanife Dilek 27/05/2011. RETURNING kullanımı için CURRENT OF kullanımı kaldırıldı.
             WHERE serial_number = eq_ekipman_sahibi_kim_rec.serial_number AND sahiplik_id = eq_ekipman_sahibi_kim_rec.sahiplik_id;

            lg_ekipman_sahibi_kim_insert ('U',
                                          v_giren_kullanici,
                                          v_serial_number,
                                          v_account_number,
                                          v_outlet_location,
                                          v_sales_agent_code,
                                          v_sebep_kodu,
                                          v_ekipman_sahibi_tipi,
                                          v_aciklama,
                                          v_iptal_sebep_kodu,
                                          v_kayit_iptal,
                                          v_kampanya_kodu,
                                          v_satis_bayii,
                                          eq_ekipman_sahibi_kim_rec.kampanya_ozellik_kodu,
                                          eq_ekipman_sahibi_kim_rec.kampanya_ozellik_degeri,
                                          eq_ekipman_sahibi_kim_rec.sahiplik_tipi,
                                          eq_ekipman_sahibi_kim_rec.ekipman_tipi,
                                          eq_ekipman_sahibi_kim_rec.sahiplik_id,
                                          eq_ekipman_sahibi_kim_rec.garanti_baslangic,
                                          odurum
                                         );

            IF TRIM (odurum) != '0' THEN
               odurum := 'Log islemi yapilamadi.' || odurum;

               IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                  CLOSE eq_ekipman_sahibi_kim_cur;
               END IF;

               RETURN;
            END IF;

            cari_islemler_pack.ekipman_borclandirma_iptal (v_account_number,
                                                           v_outlet_location,
                                                           v_serial_number,
                                                           v_sahiplik_id,
                                                           v_giren_kullanici,
                                                           v_error_type,
                                                           odurum
                                                          );

            IF v_error_type = 0 THEN
               out_uyari := '0';
               odurum    := '0';
            END IF;

            IF v_error_type = 1 THEN
               out_uyari := odurum;
               odurum    := '0';
            END IF;

            IF v_error_type = 2 THEN
               odurum := 'Borçlandirma IPTAL edilemedi :' || odurum;

               IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                  CLOSE eq_ekipman_sahibi_kim_cur;
               END IF;

               RETURN;
            END IF;

            fatura.taa_taahhut_pack.abone_taahhut_kontrol (v_account_number,
                                                           v_outlet_location,
                                                           'ES',
                                                           v_serial_number,
                                                           v_giren_kullanici,
                                                           out_taa_uyari,
                                                           odurum
                                                          );

            IF odurum <> '0' THEN
               odurum := 'FATURA.TAA_TAAHHUT_PACK.ABONE_TAAHHUT_KONTROL: TAAHHÜT ISLEMLERINDE HATA OLUSTU: ' || odurum;

               IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                  CLOSE eq_ekipman_sahibi_kim_cur;
               END IF;

               RETURN;
            END IF;

            IF v_taahhut_kontrol = 'E' THEN
               IF TRIM (out_taa_uyari) IS NOT NULL THEN
                  IF yetki_pack.yetkisi_varmi (v_giren_kullanici, 'ISLEM_EKIPMAN_TAAHHUT_UYARI_GECME') = 0 THEN
                     odurum := 'EQ_EKIPMAN_SAHIBI_KIM_INS_UPD: Islem yetkiniz yok: ' || out_taa_uyari;

                     IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
                        CLOSE eq_ekipman_sahibi_kim_cur;
                     END IF;

                     RETURN;
                  END IF;

                  out_uyari := out_uyari || ' - ' || out_taa_uyari;
               END IF;
            END IF;

            v_ittp_kayit_iptal_et      := 1;
         ELSE
            odurum := 'Bu kayıt sadece iptal edilebilir !!';

            IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
               CLOSE eq_ekipman_sahibi_kim_cur;
            END IF;

            RETURN;
         END IF;
      END IF;

      CLOSE eq_ekipman_sahibi_kim_cur;

      --
      --//===---BASLA ITTP Entegrasyon---===\\--
      --mcetinbag 20101005
      --Hanife Dilek 05/04/2011. Sahiplik tipine göre işlem yapılması
      --                         Sadece ekipman sahibi normal ve ekipman sahibi tipi üyenin ise..
      --Hanife Dilek 04/05/2011. Kartlar entegrasyona dahil edilmemeli
      OPEN cur_ekipman_tipi;

      FETCH cur_ekipman_tipi INTO v_converter_type;

      CLOSE cur_ekipman_tipi;

      -- Hanife Dilek 27.05.2011. Sahiplik tipi, ekipman sahiplik tipi ya da converter type ı değişen ekipmanlar
      -- mart 2012, Evrim
      -- Evrim Kayan, F04 EKİMANLARI KONTRAT SONuNDA HARİCEN ITTP'ye PRODUCT olarak geçiriliyor.
      -- Buradan tekrar atılması fazla olur.
      --
      IF     (v_sahipliktipi = 0 OR eq_ekipman_sahibi_kim_rec.sahiplik_tipi = 0)
         AND (v_ittp_ekipman_sahibi_tipi = 1 OR eq_ekipman_sahibi_kim_rec.ekipman_sahibi_tipi = 1)
         AND NVL (v_converter_type, 'X') != 'SC'
         AND NOT (v_franchise = 'F04' AND v_sahiplik_icin_cari_var = 1) THEN
         --Payment method hesaplamasi
         --1: NORMAL_SATIS: SIMULASYON YOK: ABR olusturulmaz, PRICE_TO_ABR cagirilmaz, DBS-Faturaya odeme bununla calisir
         --5: PESIN_SATIS: 1 aylik tutari KK ile odeme, simdi isletilir, , PRICE_TO_ABR cagirilir, DBS-Kredi Karti odeme bununla calisir
         --7: BAYIDEN_SATIS: 1 aylik tutari Bayiden odeme, uye faturasina 1 aylik kisim cikmaz, PRICE_TO_ABR cagirilir, DBS-Bayiden Satis bununla calisir

         --TODO: Hesaplama yapilmasi gerekiyor!!
         --Hanife Dilek 13/06/2011. Bayiden satış olduğuna karar vermemiz için campaign_sales_channel IN (2,4) olmalı
         DECLARE
            v_ittp_kk_tahsilat_varmi NUMBER (1);
            v_ittp_dummy             VARCHAR2 (250);
         BEGIN
            IF TRIM (v_satis_bayii) IS NOT NULL AND v_ittp_campaign_sales_channel IN (2, 4) THEN
               v_ittp_payment_method := 7;
            --kredi karti ekrani servis ekleme penceresinden sonra geldiginden bu asamada
            --kredi kari ile satis verisini gonderemeyiz. Tahsilat akislarinin ardina konacak
            --entegrasyon kodu ile cozulecektir
            ELSE
               dbs_dba.urun_ekle_tahsilat.ekipman_kk_tahsilat_varmi (in_account_number  => v_account_number,
                                                                     in_outlet_location => v_outlet_location,
                                                                     in_serial_number   => v_serial_number,
                                                                     in_islem_tarihi    => SYSDATE,
                                                                     in_kullanici       => v_giren_kullanici,
                                                                     out_tahsilat_durum => v_ittp_kk_tahsilat_varmi,
                                                                     out_kayit_sayisi   => v_ittp_dummy,
                                                                     out_tahsilat_id    => v_ittp_dummy,
                                                                     out_tahsilat_info  => v_ittp_dummy,
                                                                     out_default_kk_no  => v_ittp_dummy,
                                                                     out_def_kk_expdate => v_ittp_dummy,
                                                                     out_cvv2           => v_ittp_dummy,
                                                                     out_default_isim   => v_ittp_dummy,
                                                                     out_warn_message   => v_ittp_dummy,
                                                                     out_kk_talimat     => v_ittp_dummy,
                                                                     durum              => v_ittp_dummy
                                                                    );

               IF v_ittp_kk_tahsilat_varmi = 1 THEN
                  v_ittp_payment_method := 3;
               ELSE
                  v_ittp_payment_method := 1;
               END IF;
            END IF;
         END;

         billing_dbs_int.onl_order_ittp_pkg.bof_dbs_order_snapshot (i_integration_control_cd => 'ORDER_SAHIPLIK',
                                                                    i_account_number         => v_account_number,
                                                                    i_prospect_number        => NULL,
                                                                    o_integrate_open         => v_ittp_integ_open
                                                                   );

         IF v_ittp_integ_open = 0 AND v_ittp_payment_method = 3 THEN
            odurum := 'Üye için tahsilat entegrasyonu kapalı durumda.  Üye bilgisinde değişiklik yapılması için CC MONITORING ekibine bilgi veriniz !';
            RETURN;
         END IF;

         IF v_ittp_integ_open = 1 THEN
            billing_dbs_int.onl_order_ittp_pkg.get_offer_4_ekipman_fn (i_serial_number  => v_serial_number,
                                                                       o_offer_cd       => v_ittp_service_code,
                                                                       o_result_type    => v_result_type,
                                                                       o_result_code    => v_result_code,
                                                                       o_result_message => v_result_message
                                                                      );

            IF v_result_type <> 0 THEN
               odurum := 'ITTP Entegrasyon: ' || v_result_message;
               RETURN;
            END IF;

            IF v_ittp_sahiplik_yap = 1 THEN
               --o Hanife Dilek 31/05/2011. Charge_type = 3 ile gelen kapmanyalar ayın 4'ünde gelse bile 3'te gelmiş gibi proses edilmeli
               OPEN cur_camp_charge_type (v_kampanya_kodu);

               FETCH cur_camp_charge_type INTO v_camp_charge_type;

               CLOSE cur_camp_charge_type;

               IF v_camp_charge_type = 3 THEN
                  IF TO_CHAR (SYSDATE - 1, 'dd') = '03' THEN
                     v_effective_date := TRUNC (SYSDATE - 1);
                  END IF;
               ELSE
                  v_effective_date := SYSDATE;
               END IF;

               --o

               --Hanife Dilek 08/06/2011. Kiralıkken sahiplendirilen ekipmanların iptal kaydının ITTP'ye gelmemesi gerek.
               IF v_ittp_kayit_iptal_et = 1 AND eq_ekipman_sahibi_kim_rec.sahiplik_tipi = 0 AND eq_ekipman_sahibi_kim_rec.ekipman_sahibi_tipi = 1 THEN
                  --Bu islem ITTP dilinde bayinin SAHIP INVOLVEMENT kaydini INAKTIF yapmaktir..
                  billing_dbs_int.onl_order_ittp_pkg.set_dbs_order_snapshot (i_integration_control_cd    => 'ORDER_SAHIPLIK',
                                                                             i_dbs_order_type            => 2,
                                                                             i_payment_method            => v_ittp_payment_method,
                                                                             i_work_order_number         => NULL,
                                                                             i_wo_line_items_id          => NULL,
                                                                             i_account_number            => NULL,
                                                                             i_outlet_location           => NULL,
                                                                             i_job_code                  => 'DSR',
                                                                             i_hp_svc_id                 => NULL,
                                                                             i_on_air_activation_id      => NULL,
                                                                             i_campaign_code             => NULL,
                                                                             i_service_code              => NULL,
                                                                             i_service_frequency         => NULL,
                                                                             i_stb_tipi                  => NULL,
                                                                             i_li_effective_date         => SYSDATE,
                                                                             i_expected_effective_date   => v_effective_date,
                                                                             i_yeni_promo_bitis_tarihi   => NULL,
                                                                             i_eski_promo_bitis_tarihi   => NULL,
                                                                             i_yeni_fiyat_bitis_tarihi   => NULL,
                                                                             i_eski_fiyat_bitis_tarihi   => NULL,
                                                                             i_quantity                  => 1,
                                                                             i_reason_code               => v_iptal_sebep_kodu,
                                                                             i_non_std_svc_rate          => NULL,
                                                                             i_non_std_svc_rate_currency => NULL,
                                                                             i_non_std_svc_rate_expire   => NULL,
                                                                             i_bayiden_satis             => 0,
                                                                             i_satis_bayi_kodu           => NULL,
                                                                             i_bedelli                   => 0,
                                                                             i_sozlesme_campaign_code    => NULL,
                                                                             i_sozlesme_effective_date   => NULL,
                                                                             i_sozlesme_no               => NULL,
                                                                             i_sozlesme_status           => NULL,
                                                                             i_sahiplik_id               => v_sahiplik_id,
                                                                             i_serial_number             => v_serial_number,
                                                                             i_ekipman_sahibi_tipi       => v_ittp_ekipman_sahibi_tipi,
                                                                             i_sahip_bayi_kodu           => v_sales_agent_code,
                                                                             i_aciklama                  => v_aciklama,
                                                                             i_sahiplik_tipi             => v_sahipliktipi,
                                                                             i_process_user              => v_giren_kullanici,
                                                                             i_process_date              => SYSDATE,
                                                                             o_result_type               => v_result_type,
                                                                             o_result_code               => v_result_code,
                                                                             o_result_message            => v_result_message
                                                                            );

                  IF v_result_type <> 0 THEN
                     odurum := 'ITTP Entegrasyon: ' || v_result_message;
                     RETURN;
                  END IF;
               END IF;

               IF v_sahipliktipi = 0 AND v_ekipman_sahibi_tipi = 1 THEN
                  billing_dbs_int.onl_order_ittp_pkg.set_dbs_order_snapshot (
                     i_integration_control_cd    => 'ORDER_SAHIPLIK',
                     i_dbs_order_type            => 2,
                     i_payment_method            => v_ittp_payment_method,
                     i_work_order_number         => NULL,
                     i_wo_line_items_id          => NULL,
                     i_account_number            => v_account_number,
                     i_outlet_location           => v_outlet_location,
                     i_job_code                  => 'ADD',
                     i_hp_svc_id                 => NULL,
                     i_on_air_activation_id      => NULL,
                     i_campaign_code             => (CASE WHEN v_account_number IS NULL THEN NULL ELSE v_kampanya_kodu END),
                     i_service_code              => (CASE WHEN v_account_number IS NULL THEN NULL ELSE v_ittp_service_code END),
                     i_service_frequency         => NULL,
                     i_stb_tipi                  => (CASE WHEN v_account_number IS NULL THEN NULL ELSE v_stb_tipi END),
                     i_li_effective_date         => SYSDATE,
                     i_expected_effective_date   => v_effective_date,
                     i_yeni_promo_bitis_tarihi   => NULL,
                     i_eski_promo_bitis_tarihi   => NULL,
                     i_yeni_fiyat_bitis_tarihi   => NULL,
                     i_eski_fiyat_bitis_tarihi   => NULL,
                     i_quantity                  => 1,
                     i_reason_code               => v_ittp_sahiplik_sebep_kodu,
                     i_non_std_svc_rate          => NULL,
                     i_non_std_svc_rate_currency => NULL,
                     i_non_std_svc_rate_expire   => NULL,
                     i_bayiden_satis             => (CASE WHEN v_satis_bayii IS NOT NULL THEN 1 ELSE 0 END),
                     i_satis_bayi_kodu           => v_satis_bayii,
                     i_bedelli                   => (CASE WHEN v_account_number IS NULL THEN 0 ELSE 1 END),
                     i_sozlesme_campaign_code    => NULL,
                     i_sozlesme_effective_date   => NULL,
                     i_sozlesme_no               => NULL,
                     i_sozlesme_status           => NULL,
                     i_sahiplik_id               => v_sahiplik_id,
                     i_serial_number             => v_serial_number,
                     i_ekipman_sahibi_tipi       => v_ittp_ekipman_sahibi_tipi,
                     i_sahip_bayi_kodu           => v_sales_agent_code,
                     i_aciklama                  => v_aciklama,
                     i_sahiplik_tipi             => v_sahipliktipi,
                     i_process_user              => v_giren_kullanici,
                     i_process_date              => SYSDATE,
                     o_result_type               => v_result_type,
                     o_result_code               => v_result_code,
                     o_result_message            => v_result_message);
               END IF;

               IF v_result_type <> 0 THEN
                  odurum := 'ITTP Entegrasyon: ' || v_result_message;
                  RETURN;
               END IF;
            ELSIF v_ittp_kayit_iptal_et = 1 AND eq_ekipman_sahibi_kim_rec.sahiplik_tipi = 0 AND eq_ekipman_sahibi_kim_rec.ekipman_sahibi_tipi = 1 THEN
               billing_dbs_int.onl_order_ittp_pkg.set_dbs_order_snapshot (
                  i_integration_control_cd    => 'ORDER_SAHIPLIK',
                  i_dbs_order_type            => 2,
                  i_payment_method            => v_ittp_payment_method,
                  i_work_order_number         => NULL,
                  i_wo_line_items_id          => NULL,
                  i_account_number            => v_account_number,
                  i_outlet_location           => v_outlet_location,
                  i_job_code                  => 'DSR',
                  i_hp_svc_id                 => NULL,
                  i_on_air_activation_id      => NULL,
                  i_campaign_code             => (CASE WHEN v_account_number IS NULL THEN NULL ELSE v_kampanya_kodu END),
                  i_service_code              => (CASE WHEN v_account_number IS NULL THEN NULL ELSE v_ittp_service_code END),
                  i_service_frequency         => NULL,
                  i_stb_tipi                  => (CASE WHEN v_account_number IS NULL THEN NULL ELSE v_stb_tipi END),
                  i_li_effective_date         => SYSDATE,
                  i_expected_effective_date   => SYSDATE,
                  i_yeni_promo_bitis_tarihi   => NULL,
                  i_eski_promo_bitis_tarihi   => NULL,
                  i_yeni_fiyat_bitis_tarihi   => NULL,
                  i_eski_fiyat_bitis_tarihi   => NULL,
                  i_quantity                  => 1,
                  i_reason_code               => v_iptal_sebep_kodu,
                  i_non_std_svc_rate          => NULL,
                  i_non_std_svc_rate_currency => NULL,
                  i_non_std_svc_rate_expire   => NULL,
                  i_bayiden_satis             => (CASE WHEN v_satis_bayii IS NOT NULL THEN 1 ELSE 0 END),
                  i_satis_bayi_kodu           => v_satis_bayii,
                  i_bedelli                   => (CASE WHEN v_account_number IS NULL THEN 0 ELSE 1 END),
                  i_sozlesme_campaign_code    => NULL,
                  i_sozlesme_effective_date   => NULL,
                  i_sozlesme_no               => NULL,
                  i_sozlesme_status           => NULL,
                  i_sahiplik_id               => v_sahiplik_id,
                  i_serial_number             => v_serial_number,
                  i_ekipman_sahibi_tipi       => v_ekipman_sahibi_tipi,
                  i_sahip_bayi_kodu           => v_sales_agent_code,
                  i_aciklama                  => v_aciklama,
                  i_sahiplik_tipi             => v_sahipliktipi,
                  i_process_user              => v_giren_kullanici,
                  i_process_date              => SYSDATE,
                  o_result_type               => v_result_type,
                  o_result_code               => v_result_code,
                  o_result_message            => v_result_message);

               IF v_result_type <> 0 THEN
                  odurum := 'ITTP Entegrasyon: ' || v_result_message;
                  RETURN;
               END IF;
            END IF;
         END IF;

         billing_dbs_int.onl_order_ittp_pkg.eof_dbs_order_snapshot (i_integration_control_cd => 'ORDER_SAHIPLIK',
                                                                    i_account_number         => v_account_number,
                                                                    i_dbs_order_type         => 2,
                                                                    o_result_type            => v_result_type,
                                                                    o_result_code            => v_result_code,
                                                                    o_result_message         => v_result_message
                                                                   );

         IF v_result_type <> 0 THEN
            odurum := 'ITTP Entegrasyon: ' || v_result_message;
            RETURN;
         END IF;
      END IF;
   --\\===---BITIR ITTP Entegrasyon---===//--
   --
   EXCEPTION
      WHEN OTHERS THEN
         IF eq_ekipman_sahibi_kim_cur%ISOPEN THEN
            CLOSE eq_ekipman_sahibi_kim_cur;
         END IF;

         odurum := SQLERRM;
   END;

   FUNCTION ekipman_sahibi (in_account_number IN NUMBER, in_outlet_location IN VARCHAR2, in_ekipman_tipi IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_serial_number eq_ekipman_sahibi_kim.serial_number%TYPE;
   BEGIN
      BEGIN
         -- Birden fazla sahiplik olmasi durumunda en son aktif olan dikkate alinir.
         SELECT serial_number
           INTO v_serial_number
           FROM (SELECT   serial_number
                     FROM eq_ekipman_sahibi_kim
                    WHERE     account_number = in_account_number
                          AND outlet_location = in_outlet_location
                          AND ekipman_sahibi_tipi = 1
                          AND kayit_iptal = 'H'
                          AND ekipman_tipi = in_ekipman_tipi
                 ORDER BY degistirme_tarihi DESC)
          WHERE ROWNUM = 1;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END;

      RETURN v_serial_number;
   END;

   FUNCTION ekipman_sahibi_kim (iserial_number       IN     wiz_equip.serial_number%TYPE,
                                oekipman_sahibi_tipi    OUT eq_ekipman_sahibi_kim.ekipman_sahibi_tipi%TYPE,
                                ooutlet_location        OUT eq_ekipman_sahibi_kim.outlet_location%TYPE
                               )
      RETURN VARCHAR2 IS
      v_uye_no eq_ekipman_sahibi_kim.account_number%TYPE;
      v_ts_no  eq_ekipman_sahibi_kim.sales_agent_code%TYPE;
   BEGIN
      BEGIN
         SELECT account_number, outlet_location, sales_agent_code, ekipman_sahibi_tipi
           INTO v_uye_no, ooutlet_location, v_ts_no, oekipman_sahibi_tipi
           FROM eq_ekipman_sahibi_kim
          WHERE serial_number = iserial_number AND kayit_iptal = 'H';
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END;

      IF TRIM (oekipman_sahibi_tipi) = 1 THEN
         RETURN v_uye_no;
      ELSIF TRIM (oekipman_sahibi_tipi) = 2 THEN
         ooutlet_location := NULL;
         RETURN v_ts_no;
      ELSE
         RETURN NULL;
      END IF;
   END;

   PROCEDURE wiz_equip_to_abone_insert (ekipman_no         IN     wiz_equip.serial_number%TYPE,
                                        is_emri_no         IN     wiz_equip.work_order_number%TYPE,
                                        outlet             IN     wiz_equip.outlet_location%TYPE,
                                        teknisyen_kodu     IN     wiz_equip.technician%TYPE,
                                        telefon_baglantisi IN     VARCHAR2,
                                        kullanici_kodu     IN     wiz_equip_trx.operator_id%TYPE,
                                        out_trx_tarih         OUT wiz_equip_trx.trx_date%TYPE,
                                        status                OUT VARCHAR2,
                                        sebep_kodu         IN     VARCHAR2
                                       ) IS
      v_is_emri_no               wiz_equip.work_order_number%TYPE;
      v_uye_no                   wiz_equip.account_number%TYPE;
      v_uye_no1                  wiz_equip.account_number%TYPE;
      v_bina_no                  wiz_equip.service_address_id%TYPE;
      v_manufacturer             wiz_equip.manufacturer%TYPE;
      v_converter_type           wiz_equip.converter_type%TYPE;
      v_converter_model          wiz_equip.converter_model%TYPE;
      v_teknisyen_kodu           wiz_equip.technician%TYPE;
      v_kullanici_kodu           wiz_equip_trx.operator_id%TYPE;
      v_outlet                   wiz_equip.outlet_location%TYPE;
      v_deger                    pa_sabitler.deger%TYPE;
      v_status1                  VARCHAR2 (255);
      v_status2                  VARCHAR2 (255);
      v_co_kull_kod              co_kullanici.kod%TYPE;
      v_gca                      VARCHAR2 (255);
      v_sonuc                    VARCHAR2 (512);
      v_uye_stb_tipi             wiz_customer_hp_life.hp_cluster%TYPE;
      v_sc_ekipman_no            wiz_equip.serial_number%TYPE;
      v_st_ekipman_no            wiz_equip.serial_number%TYPE;
      v_md_ekipman_no            wiz_equip.serial_number%TYPE;
      v_equip_location_code      wiz_equip.equip_location_code%TYPE;
      v_serial_sahiplik          wiz_equip.serial_number%TYPE;
      v_ozellik_satilik          VARCHAR2 (1);
      v_chipset_seri_no          VARCHAR2 (20);
      v_irdetodestekliekipman    VARCHAR2 (1);
      v_manufactureruyumlu       VARCHAR2 (1);
      v_tra_id                   NUMBER;
      v_swap_status              VARCHAR2 (100);
      v_result                   NUMBER (1);
      v_count                    NUMBER;
      v_uye_tipi                 wiz_customer_hp_life.customer_type%TYPE;

      v_franchise_code           wiz_customer_hp_life.franchise_code%TYPE;
      v_ekipman_tip_matrix_id    NUMBER (10);
      v_eslenik_durum            BOOLEAN;
      v_eslenik_hata             BOOLEAN;
      v_ch_serial_number         VARCHAR2 (20);
      v_sc_serial_number         VARCHAR2 (20);
      v_sc_durum                 VARCHAR2 (1);
      v_sc_serial_number_eski    VARCHAR2 (20);
      v_sc_durum_eski            VARCHAR2 (1);
      v_st_no                    VARCHAR2 (20);
      v_st_durum                 VARCHAR2 (1);
      v_sozlesme_no              VARCHAR2 (20);
      v_sozlesme_durum           VARCHAR2 (1);
      v_modul_no                 VARCHAR2 (20);
      v_modul_durum              VARCHAR2 (1);
      v_modul_tip                VARCHAR2 (20);
      v_chip_durum               VARCHAR2 (1);
      v_stokkodu                 VARCHAR2 (20);
      v_eslenik_id               NUMBER;
      v_st_md_type               VARCHAR2 (2);
      v_st_md_serial_number      VARCHAR2 (20);
      v_uye_uydusu               NUMBER (2);
      v_fta60_mesaj              VARCHAR2 (200);
      v_mac_oncesi_dakika_kisti  NUMBER;
      o_rating_destekli_mi       VARCHAR2 (1);
      o_eq_ekipman_tip_matrix_id NUMBER;
   BEGIN
      v_status1 := ' ';
      v_status2 := ' ';

      /*ENTEGRASYON Mustafa Abiye sorulacak*/
      --DEĞİŞMEYECEK
      SELECT account_number, service_address_id
        INTO v_uye_no, v_bina_no
        FROM wiz_work_order
       WHERE work_order_number = is_emri_no;

      BEGIN -- ekipman sistemde var mi ? ve bosta mi ?
         SELECT manufacturer, account_number, converter_type, converter_model, equip_location_code
           INTO v_manufacturer, v_uye_no1, v_converter_type, v_converter_model, v_equip_location_code
           FROM wiz_equip
          WHERE serial_number = ekipman_no;

         IF v_uye_no1 <> 0 THEN
            v_status1 := 'Ekipman Abonede';
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_status1 := 'Ekipman Sistemde Yok';
      END;

      IF LENGTH (outlet) = 3 THEN
         BEGIN -- outlette ekipman var mi ?
            SELECT account_number
              INTO v_uye_no1
              FROM wiz_equip
             WHERE account_number = v_uye_no AND outlet_location = outlet AND TRIM (converter_type) = TRIM (v_converter_type);

            IF v_uye_no1 <> 0 THEN
               v_status2 := 'Abonede bu Outlet Için Ekipman Var. Uye_No :' || v_uye_no1;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_status2 := ' ';
         END;
      ELSE
         v_status1 := 'Hatali Outlet Bilgisi' || outlet || 'outlet';
      END IF;

      -- kullanici kontrolÜ
      IF RTRIM (LTRIM (kullanici_kodu)) IS NULL THEN
         v_status1 := 'Hatali Kullanici Girildi';
      ELSE
         BEGIN
            SELECT co_kullanici.wiz_operator_id, co_kullanici.kod
              INTO v_kullanici_kodu, v_co_kull_kod
              FROM co_kullanici
             WHERE co_kullanici.wiz_operator_id = kullanici_kodu;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_status1 := 'Hatali Kullanici Kodu ';
         END;
      END IF;

      BEGIN
         SELECT bt_bayi_teknik_servis.sales_agent_code
           INTO v_teknisyen_kodu
           FROM bt_bayi_teknik_servis
          WHERE bt_bayi_teknik_servis.sales_agent_code = teknisyen_kodu;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_status1 := teknisyen_kodu || 'Kullanici da hiç teknisyen kodu yok ki?';
      END;

      IF NOT (v_status1 = ' ' AND v_status2 = ' ') THEN
         status := v_status1 || v_status2;
         RETURN;
      END IF;

      SELECT customer_type, franchise_code
        INTO v_uye_tipi, v_franchise_code
        FROM wiz_customer_hp_life
       WHERE account_number = v_uye_no;

      IF TRIM (v_uye_no) IS NOT NULL THEN
         v_uye_stb_tipi := vestel_pack.abone_stb_tipi_bul (TRIM (v_uye_no));

         IF v_uye_stb_tipi = '-1' THEN
            status := 'Üye Stb Tipi Bulunamadi.';
            RETURN;
         END IF;
      END IF;

      -- Sporlu pakette kullanılmayan ekipman ve abone kontrolu
      IF yetki_pack.yetkisi_varmi (v_co_kull_kod, 'ISLEM_SERVIS_EKLE_SPORLU_PAKET') = 0 THEN
         SELECT COUNT (1)
           INTO v_count
           FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit (TRIM ('SPORLU_PAKETTE_EKIPMAN_KONTROLU'))))
          WHERE COLUMN_VALUE = v_franchise_code || ':' || v_uye_tipi;

         IF v_count > 0 -- franchise ve uye tipi uyuyorsa
                       THEN
            v_ekipman_tip_matrix_id := NULL;

            IF v_converter_type = 'ST' THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_equip w
                WHERE w.account_number = v_uye_no AND w.outlet_location = outlet AND w.converter_type = 'SC';
            ELSE
               v_count := 1;
            END IF;

            IF v_count > 0 THEN
               BEGIN
                  SELECT eq_ekipman_tip_matrix_id
                    INTO v_ekipman_tip_matrix_id
                    FROM eq_ekipman_tip_matrix e
                   WHERE     TRIM (e.converter_type) = TRIM (v_converter_type)
                         AND TRIM (e.manufacturer) = TRIM (v_manufacturer)
                         AND TRIM (e.converter_model) = TRIM (v_converter_model);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;
               END;

               SELECT COUNT (1)
                 INTO v_count
                 FROM pr_urun_ozellik_tanim
                WHERE ozellik_kodu = 98 AND urun_tipi = 6 AND ekipman_tip_matrix_id = v_ekipman_tip_matrix_id;

               IF v_count > 0 THEN
                  SELECT COUNT (1)
                    INTO v_count
                    FROM dbs_addr_cas_services cc,
                         dbs_addr_dbs_cas_services cdd
                   WHERE     cc.code = cdd.cas_code
                         AND cc.product_number IN (SELECT product_number
                                                     FROM dbs_addr.dbs_addr_cas_services_group
                                                    WHERE code IN (3, 4))
                         AND NOT EXISTS
                                (SELECT 1
                                   FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit (TRIM ('SPORLU_PAKETTE_HARICI_SERVISLER'))))
                                  WHERE COLUMN_VALUE = cdd.dbs_code)
                         AND (   EXISTS
                                    (SELECT 1
                                       FROM wiz_customer_hp_svc
                                      WHERE     account_number = v_uye_no
                                            AND outlet_location = outlet
                                            AND service_code = cdd.dbs_code
                                            AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                                     UNION
                                     SELECT 1
                                       FROM dt_dbs_int_dba.vv_uye_ittp_servisler s
                                      WHERE     s.account_number = v_uye_no
                                            AND s.outlet_location = outlet
                                            AND s.service_code = cdd.dbs_code
                                            AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT'))
                              OR EXISTS
                                    -- Murat AYDIN 25122013 ITTP ENTEGRASYON
                                 (SELECT 1
                                    FROM wiz_wo_line_items l,
                                         wiz_work_order w
                                   WHERE     w.work_order_number = l.work_order_number
                                         AND w.account_number = v_uye_no
                                         AND l.outlet_location = outlet
                                         AND w.wo_status IN ('O', 'P')
                                         AND l.wo_status = 'O'
                                         AND l.job_code = 'ADD'
                                         AND l.service_code = cdd.dbs_code
                                         AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                                  UNION
                                  SELECT 1
                                    FROM dt_dbs_int_dba.vv_ittp_customer_order wo
                                   WHERE     wo.dbs_outlet_location = outlet
                                         AND wo.dbs_account_number = v_uye_no
                                         AND wo.work_order_statu = ('ACIK')
                                         AND wo.work_line_statu = ('ACIK')
                                         AND wo.job_code = 'ADD'
                                         AND wo.havadan_flag = 0
                                         AND wo.service_code = cdd.dbs_code
                                         AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')));

                  IF v_count > 0 -- Sporlu Paket ise
                                THEN
                     status := 'EKLENİLEN EKİPMAN İLE SPORLU PAKET KULLANILAMAZ.';
                     RETURN;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      -- PVR kutu ekipman eklemek için, üye üzerindeki kart da IRDETO destekli olmali,
      -- Kutu ve kart IRDETO sinyal sistemi ile çalisacaksa eslesebilir.
      -- Eski tip kutu ve kart düsürüldükten sonra PVR kutu ve kart eklenebilir.
      ekipman_irdeto_desteklimi (v_uye_no,
                                 outlet,
                                 ekipman_no,
                                 v_manufacturer,
                                 v_converter_type,
                                 v_converter_model,
                                 'E',
                                 v_sc_ekipman_no,
                                 v_st_ekipman_no,
                                 v_md_ekipman_no,
                                 v_manufactureruyumlu,
                                 v_irdetodestekliekipman,
                                 status
                                );

      IF status <> '0' THEN
         RETURN;
      END IF;

      IF v_manufactureruyumlu = 'H' THEN
         status := 'Kart ve Kutu\Modül uyumlu degil, IRDETO ekipman ile IRDETO kart eklenebilir.';
         RETURN;
      END IF;

      SELECT SYSDATE INTO out_trx_tarih FROM DUAL;

      UPDATE wiz_equip
         SET wiz_equip.converter_id        = 1,
             wiz_equip.polled_date         = SYSDATE,
             wiz_equip.equip_location_code = '   ',
             wiz_equip.service_address_id  = v_bina_no,
             wiz_equip.account_number      = v_uye_no,
             wiz_equip.outlet_location     = outlet,
             wiz_equip.work_order_number   = is_emri_no,
             wiz_equip.technician          = v_teknisyen_kodu,
             wiz_equip.install_date        = out_trx_tarih,
             wiz_equip.mpaa_rating_degree  = 1,
             wiz_equip.distributor_code    = 'H01',
             wiz_equip.secondary_conv_info = v_co_kull_kod
       WHERE serial_number = ekipman_no;

      INSERT INTO wiz_equip_trx (serial_number, manufacturer, work_order_number, account_number, trx_date, operator_id, technician, repair_code, new_location)
           VALUES (ekipman_no, v_manufacturer, is_emri_no, v_uye_no, out_trx_tarih, v_kullanici_kodu, v_teknisyen_kodu, '   ', '   ');

      ------------------------------
      IF v_irdetodestekliekipman = 'E' THEN
         status := '0';

         -- Kart seri no elimizde ise;
         IF v_sc_ekipman_no NOT IN ('-1', '-2') THEN
            -- Abone üzerinde kutu varsa, pair çikilir
            -- kart degisikligi ise, swap sinyali de çikilmalidir
            v_swap_status := 1;

            -- swap'den status = 0 döndüyse, kart degisimidir, swap ile sektor bilgisi tasinmistir, overwrtie_sector çikmaz
            -- swap'den 1 döndüyse, yeni kart eklemedir, swap sinyali çikmamistir.

            -- Burası üye üzerinde hem kart hemde kutu veya modülün olduğu yer.
            IF v_st_ekipman_no NOT IN ('-1', '-2') OR v_md_ekipman_no NOT IN ('-1', '-2') THEN
               -- İrdeto da patch çıkılmamış kartlar için maç varsa aktivasyon dahil hiç bir işlem yaptırılmayacak. illegal talebi.
               IF NOT dbs_dba.kart_patch_kontrol (v_sc_ekipman_no) -- TRUE ise kart patch edilmiş.
                                                                  THEN
                  IF yetki_pack.yetkisi_varmi (v_co_kull_kod, 'CARD_RESET_KISIT_GECME') = 0 THEN
                     v_mac_oncesi_dakika_kisti := NVL (TRIM (dbs_dba.dbs_sabit ('CARD_RESET_DAKIKA_KISTI')), 60);

                     SELECT COUNT (1)
                       INTO v_count
                       FROM dbs_dba.mb_lig_fikstur_event f,
                            prod_dba.wiz_ppv_events e
                      WHERE     f.ppv_event_id = e.event_id
                            AND SYSDATE BETWEEN f.hafta_begin_date AND f.hafta_end_date
                            AND SYSDATE BETWEEN e.event_end_time - ( (2 + (v_mac_oncesi_dakika_kisti / 60)) / 24) AND e.event_end_time;

                     IF v_count > 0 THEN
                        status := 'Hata : Unrecoverable Smart Card Memory Conflict Detected..! ';
                        RETURN;
                     END IF;
                  END IF;
               END IF;

               /* Karti degisen aboneler için, eger eski kutusu duruyorsa, bu kutudaki videolari izleyebilmesi için swap sinyali gerekiyor
               Bu sıralama daha önceden Swap - unpair - pair iken dana sonra Unpair - swap - pair(26042010) şekline dönüştürüldü.
               En son eşlenik kart bilgisini kaybetmemek için pair swaptan önce idi ama bunun değiştirilmesini talebi doğrultusunda
               Unpair - Pair - Swap sıralaması (22112011) şeklinde değiştirildi. */

               -- 18.03.2011 Falamur Öncelikle sinyal eşleği kaydı var mı diye bakılıyor. Eğer var ise ona göre kontrol ve işlemler yapılıyor.
               -- Eğer Sinyal eşleniği yok ise bu durumda unpair eşleniği var mi diye kontrol ediliyor.
               -- Unpair eşleniği olması bizde eşlenik kaydı bulunmuyor ama cas da ilgili kayıt ile sinyal olarak eşlenik olduğu bozulmadığı anlamına geliyor.
               stok_dba.dp_stok_eslenik.eslenik_bul (v_sc_ekipman_no,
                                                     'SC',
                                                     v_sc_serial_number,
                                                     v_sc_durum,
                                                     v_st_no,
                                                     v_st_durum,
                                                     v_sozlesme_no,
                                                     v_sozlesme_durum,
                                                     v_modul_no,
                                                     v_modul_durum,
                                                     v_modul_tip,
                                                     v_ch_serial_number, --
                                                     v_chip_durum,
                                                     v_stokkodu,
                                                     v_eslenik_id,
                                                     'S'
                                                    );

               IF v_eslenik_id > 0 THEN
                  IF    (v_st_ekipman_no NOT IN ('-1', '-2') AND v_st_no = v_st_ekipman_no AND v_st_durum = 'E')
                     OR (v_md_ekipman_no NOT IN ('-1', '-2') AND v_modul_no = v_md_ekipman_no AND v_modul_durum = 'E') THEN
                     v_eslenik_hata  := FALSE;
                     v_eslenik_durum := TRUE;
                  ELSE
                     v_eslenik_hata  := TRUE;
                     v_eslenik_durum := FALSE;
                  END IF;
               ELSE
                  stok_dba.dp_stok_eslenik.eslenik_bul (v_sc_ekipman_no,
                                                        'SC',
                                                        v_sc_serial_number,
                                                        v_sc_durum,
                                                        v_st_no,
                                                        v_st_durum,
                                                        v_sozlesme_no,
                                                        v_sozlesme_durum,
                                                        v_modul_no,
                                                        v_modul_durum,
                                                        v_modul_tip,
                                                        v_ch_serial_number, --
                                                        v_chip_durum,
                                                        v_stokkodu,
                                                        v_eslenik_id,
                                                        'U'
                                                       );

                  IF v_eslenik_id > 0 THEN
                     IF    (v_st_ekipman_no NOT IN ('-1', '-2') AND v_st_no = v_st_ekipman_no AND v_st_durum = 'E')
                        OR (v_md_ekipman_no NOT IN ('-1', '-2') AND v_modul_no = v_md_ekipman_no AND v_modul_durum = 'E') THEN
                        v_eslenik_hata  := FALSE;
                        v_eslenik_durum := FALSE;
                     ELSE
                        v_eslenik_hata  := TRUE;
                        v_eslenik_durum := FALSE;
                     END IF;
                  ELSE
                     v_eslenik_hata  := FALSE;
                     v_eslenik_durum := FALSE;
                  END IF;
               END IF;

               IF     NVL (dbs_sabit ('UNPAIR_SINYALI_CIKILMASIN'), 'H') = 'E'
                  AND INSTR (dbs_sabit ('UNPAIR_CIKILMAYACAK_FRANCHISE_LISTESI'), v_franchise_code) > 0
                  AND v_eslenik_hata = TRUE THEN
                  status := 'Kart eşleniği olan kutu veya modül ile eklenebilir !!!';
                  RETURN;
               END IF;

               /* falamur 22042010 unpair sinyali eklendir.*/
               -- MD ve ST birlikte var ise MD gönder ST yi NULL gönder
               IF v_eslenik_durum = FALSE THEN
                  addressability_pack.unpairchip (CASE WHEN TRIM (v_md_ekipman_no) NOT IN ('-1', '-2') THEN NULL ELSE v_st_ekipman_no END,
                                                  v_sc_ekipman_no,
                                                  CASE WHEN TRIM (v_md_ekipman_no) NOT IN ('-1', '-2') THEN v_md_ekipman_no ELSE NULL END,
                                                  v_co_kull_kod,
                                                  status
                                                 );

                  IF NVL (status, '0') <> '0' THEN
                     RETURN;
                  END IF;
               END IF;

               -- 22112011 Falamur Pair sinyali swap sinyalinden önceye alındığından dolayı eşlenik bilgisi kayboluyor.
               -- Pair sinyalinden daha önce eski eşlenik kart bilgisinin bulunması gerekiyor.
               IF TRIM (v_md_ekipman_no) NOT IN ('-1', '-2') THEN
                  v_st_md_type          := 'MD';
                  v_st_md_serial_number := v_md_ekipman_no;
               ELSIF TRIM (v_st_ekipman_no) NOT IN ('-1', '-2') THEN
                  v_st_md_type          := 'ST';
                  v_st_md_serial_number := v_st_ekipman_no;
               END IF;

               -- Bu kutunun ve modülün son eşlenik olduğu kartı bul.
               stok_dba.dp_stok_eslenik.eslenik_bul (v_st_md_serial_number,
                                                     v_st_md_type,
                                                     v_sc_serial_number_eski,
                                                     v_sc_durum_eski,
                                                     v_st_no,
                                                     v_st_durum,
                                                     v_sozlesme_no,
                                                     v_sozlesme_durum,
                                                     v_modul_no,
                                                     v_modul_durum,
                                                     v_modul_tip,
                                                     v_ch_serial_number,
                                                     v_chip_durum,
                                                     v_stokkodu,
                                                     v_eslenik_id
                                                    );
               addressability_pack.pairchip (CASE WHEN TRIM (v_md_ekipman_no) NOT IN ('-1', '-2') THEN NULL ELSE v_st_ekipman_no END,
                                             v_sc_ekipman_no,
                                             CASE WHEN TRIM (v_md_ekipman_no) NOT IN ('-1', '-2') THEN v_md_ekipman_no ELSE NULL END,
                                             v_co_kull_kod,
                                             status
                                            );

               IF NVL (status, '0') <> '0' THEN
                  RETURN;
               END IF;

               -- 22.11.2011 falamur reactivate_secure_client ve overwrite_sector sinyalleri daha önceden swap değilse çıkılıyordu.
               -- Çünkü aynı sinyaller swap içinde çıkılıyordu. Simdi kart eklemesinde her zaman çıksın isteniyor.
               -- Swap işleminde 2. defa çıkmaları sorun değil.
               IF dbs_addr_reqs_pisys_pack.reactivate_secure_client ('42', v_sc_ekipman_no, SYSDATE, v_co_kull_kod, v_tra_id, status) <> 1 THEN
                  RETURN;
               END IF;

               IF dbs_addr_reqs_pisys_pack.overwrite_sector ('33', v_sc_ekipman_no, 'TUR', 'TR', NULL, SYSDATE, v_co_kull_kod, v_tra_id, status) <> 1 THEN
                  RETURN;
               END IF;

               IF addressability_pack.sodate (v_sc_ekipman_no, SYSDATE, v_co_kull_kod, status) <> 1 THEN
                  RETURN;
               END IF;

               IF dbs_addr_reqs_pisys_pack.pair_chipset ('31', v_sc_ekipman_no, v_ch_serial_number, SYSDATE, v_co_kull_kod, v_tra_id, status) <> 1 THEN
                  RETURN;
               ELSE
                  status := '0';
               END IF;

               -- Eğer pair öncesi eşlenik kartı var ise o zaman swap çıkılacak mı diye kontrol ediliyor.
               -- Pair öncesi eşleniğinin olması illa swap çıkacak demek olmuyor. Swap içinde ki kod buna karar veriyor.
               IF TRIM (v_sc_serial_number_eski) IS NOT NULL THEN
                  addressability_pack.swapsmartcard (v_sc_ekipman_no,
                                                     CASE WHEN TRIM (v_md_ekipman_no) NOT IN ('-1', '-2') THEN NULL ELSE v_st_ekipman_no END,
                                                     CASE WHEN TRIM (v_md_ekipman_no) NOT IN ('-1', '-2') THEN v_md_ekipman_no ELSE NULL END,
                                                     TRIM (v_sc_serial_number_eski),
                                                     v_co_kull_kod,
                                                     v_swap_status
                                                    );

                  IF NVL (v_swap_status, '0') <> '0' AND NVL (v_swap_status, '1') <> '1' THEN
                     status := v_swap_status;
                     RETURN;
                  END IF;
               END IF;

               SELECT COUNT (1)
                 INTO v_count
                 FROM mb_abone_ozellik
                WHERE account_number = v_uye_no AND (outlet_location = outlet OR outlet_location IS NULL) AND abone_ozellik_kodu = 216;

               IF v_count > 0 THEN
                  addressability_pack.dbs_add_subscription (v_sc_ekipman_no, v_co_kull_kod, 7301, status);

                  IF NVL (status, '0') <> '0' THEN
                     RETURN;
                  END IF;

                  -- bozturkmen - LIGTV blackout
                  addressability_pack.dbs_add_subscription (v_sc_ekipman_no, v_co_kull_kod, 5300, status);

                  IF NVL (status, '0') <> '0' THEN
                     RETURN;
                  END IF;
               -- bozturkmen - LIGTV blackout
               END IF;

               -- Eğer pvr kutu ise recording yetkisi ekleniyor. Degilse burada hata dönmüyor. Farklı hatalar var ise o zaman hata veriliyor.
               addressability_pack.dbs_set_pvr_functionality (v_sc_ekipman_no, 1, 0, v_co_kull_kod, status);

               IF NVL (status, '0') <> '0' THEN
                  RETURN;
               END IF;

               --aşağısı kutuda tutulan bilgiler için çıkılan sinyaller
               IF sebep_kodu <> 'YKO' THEN
                  BEGIN
                     SELECT COUNT (1)
                       INTO v_count
                       FROM wiz_customer_hp_life life
                      WHERE     life.account_number = v_uye_no
                            AND life.franchise_code IN ('F01', 'F02')
                            AND EXISTS
                                   (SELECT 1
                                      FROM wiz_equip e,
                                           eq_ekipman_tip_matrix m,
                                           pr_urun_ozellik_tanim t
                                     WHERE     e.serial_number = v_st_ekipman_no
                                           AND TRIM (m.manufacturer) = TRIM (e.manufacturer)
                                           AND TRIM (m.converter_model) = TRIM (e.converter_model)
                                           AND TRIM (m.converter_type) = TRIM (e.converter_type)
                                           AND t.urun_tipi = 6
                                           AND m.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                                           AND t.ozellik_kodu = 69);

                     IF v_count > 0 THEN
                        v_uye_uydusu := abone_sorgu_pack.uye_uydusu (v_uye_no, outlet);

                        SELECT COUNT (1)
                          INTO v_count
                          FROM dbs_dba.mb_abone_ozellik mb
                         WHERE mb.account_number = v_uye_no AND mb.outlet_location = outlet AND mb.abone_ozellik_kodu = 166;

                        IF v_uye_uydusu = 2 OR v_count > 0 THEN
                           addressability_pack.setothermode (v_uye_no, v_sc_ekipman_no, v_st_ekipman_no, '1', 'SYSTEM', status);

                           IF status <> '0' THEN
                              RETURN;
                           END IF;
                        END IF;
                     END IF;
                  END;
               END IF;

               abone_batch_pack.fta_60_sinyali (v_uye_no, v_uye_no, SYSDATE - 1, outlet, status, v_fta60_mesaj, v_sc_ekipman_no);

               IF status <> '0' THEN
                  status := '0';
               END IF;

               -- interaktif bilgiler silinecek. Hata olsa bile ignore et. 11072011 falamur
               addressability_pack.dbs_clear_3pa_data_pisys (v_sc_ekipman_no, v_co_kull_kod, status);

               IF NVL (status, '0') <> '0' THEN
                  status := '0';
               END IF;

               -- Irdeto da PIN kodu kartta değil kutuda saklanıyor.
               -- O nedenle kutu ekleme işleminde pin_kodu sıfırlama yapılıyor.
               -- Sadece kart değişiyorsa, üye mevcut PIN kodunu kullanmaya devam edebilir.
               v_result := dbs_addr_reqs_pack.reset_password (7, v_sc_ekipman_no, SYSDATE, v_co_kull_kod, status);

               IF NVL (status, '0') <> '0' THEN
                  status := '0';
               END IF;

               -- Kutu veya kart degisiyor ise de, abonedeki SC ye GCA veya TMS'in güncel degeri gönderilir.
               -- Kart kill ise, bu kartın üyeye eklenmesine izin verilmiyor.
               -- Üyede MEVCUT bulunan kart kill ise, kutu hareketlerine izin verilir ama sinyalleri çıkılmaz.
               IF     ekipman_durumu_pack.dummy_mi (v_sc_ekipman_no) = 0
                  AND ekipman_durumu_pack.sinyal_gon_engellenmis_mi (v_sc_ekipman_no) = 0
                  AND ekipman_durumu_pack.kill_mi (v_sc_ekipman_no) = 0 THEN
                  -- Karta, abone, ekipman vs ile ilgili profili göndeririz.
                  -- Bu bilgi global mesaj gönderiminde kullanilir.
                  dbs_addr_reqs_pack.find_set_gca (v_sc_ekipman_no, v_co_kull_kod, status, ppvr => v_irdetodestekliekipman);

                  IF status <> '0' THEN
                     RETURN;
                  END IF;
               END IF;

               IF NVL (dbs_sabit ('RATING_OZELLIK_KONTROL_TIPI'), '0') = '0' THEN
                  abone_detay_pack.mb_abone_rating_yetki (v_uye_no, outlet, 1, 1, v_co_kull_kod, v_sonuc);
               ELSIF v_st_ekipman_no NOT IN ('-1', '-2') THEN
                  ekipman_pack.ekipman_ozellik (v_st_ekipman_no, NULL, NULL, 84, o_rating_destekli_mi, o_eq_ekipman_tip_matrix_id);

                  IF o_rating_destekli_mi = 'E' THEN
                     abone_detay_pack.mb_abone_rating_yetki (v_uye_no, outlet, 1, 1, v_co_kull_kod, v_sonuc);
                  END IF;
               END IF;

               IF v_sonuc <> '0' THEN
                  status := v_sonuc;
                  RETURN;
               END IF;
            END IF; -- v_st_ekipman_no NOT IN ('-1', '-2') OR v_md_ekipman_no NOT IN ('-1', '-2')
         END IF; -- v_sc_ekipman_no NOT IN ('-1', '-2')
      ELSE -- IRDETO-CW -- v_irdetodestekliekipman = 'E'
         --            -- Ekipman yeni bir üyeye verilirken üzerindeki ad ve fatura bilgileri silinir.
         --            -- emm_for_stb hata dönse bile ekipman ekleme islemi kesilmez, devam edilir.
         --            IF dbs_addr_reqs_pack.emm_for_stb (22,
         --                                               v_sc_ekipman_no,
         --                                               LPAD ('0', 132, '0'),
         --                                               v_gca,
         --                                               SYSDATE,
         --                                               v_co_kull_kod,
         --                                               status
         --                                              ) <> 1
         --            THEN
         --               status := '0';
         --            ELSE
         --               status := '0';
         --            END IF;
         -- Bu işlem cyripto için tüm interactive dataları siliyor
         IF dbs_addr.dbs_addr_reqs_pack.clear_3pa_data ('2', v_sc_ekipman_no, 'EEPROM;FLASH', SYSDATE, v_co_kull_kod, status, 'FFFFFFFF', 8, 1, 1, 101) <> 1 THEN
            status := '0';
         ELSE
            status := '0';
         END IF;

         IF v_converter_type = 'SC' THEN
            v_result := dbs_addr_reqs_pack.reset_password (7, v_sc_ekipman_no, SYSDATE, v_co_kull_kod, status);
         END IF;

         -- Kutu veya kart degisiyor ise de, abonedeki SC ye GCA veya TMS'in güncel degeri gönderilir.
         -- Kart kutu birlikte olucna çıkılacak sinyallerin düzeltilmesi
         -- Kart kill ise, bu kartın üyeye eklenmesine izin verilmiyor.
         -- Üyede MEVCUT bulunan kart kill ise, kutu hareketlerine izin verilir ama sinyalleri çıkılmaz.
         IF v_sc_ekipman_no NOT IN ('-1', '-2') THEN
            IF     ekipman_durumu_pack.dummy_mi (v_sc_ekipman_no) = 0
               AND ekipman_durumu_pack.sinyal_gon_engellenmis_mi (v_sc_ekipman_no) = 0
               AND ekipman_durumu_pack.kill_mi (v_sc_ekipman_no) = 0 THEN
               -- Karta, abone, ekipman vs ile ilgili profili göndeririz.
               -- Bu bilgi global mesaj gönderiminde kullanilir.
               dbs_addr_reqs_pack.find_set_gca (v_sc_ekipman_no, v_co_kull_kod, status, ppvr => v_irdetodestekliekipman);

               IF status <> '0' THEN
                  RETURN;
               END IF;
            END IF;
         END IF;

         IF NVL (dbs_sabit ('RATING_OZELLIK_KONTROL_TIPI'), '0') = '0' THEN
            abone_detay_pack.mb_abone_rating_yetki (v_uye_no, outlet, 1, 1, v_co_kull_kod, v_sonuc);
         ELSIF v_st_ekipman_no NOT IN ('-1', '-2') THEN
            ekipman_pack.ekipman_ozellik (v_st_ekipman_no, NULL, NULL, 84, o_rating_destekli_mi, o_eq_ekipman_tip_matrix_id);

            IF o_rating_destekli_mi = 'E' THEN
               abone_detay_pack.mb_abone_rating_yetki (v_uye_no, outlet, 1, 1, v_co_kull_kod, v_sonuc);
            END IF;
         END IF;

         IF v_sonuc <> '0' THEN
            status := v_sonuc;
            RETURN;
         END IF;
      END IF;

      --dtvcaloglu 22.01.2013 ****** kart ise son 5 haneye göre şifreler.
      IF v_converter_type = 'SC' THEN
         --MKECECI - 19.12.2014 -- şifreler artık random olarak belirleniyor
         --bu yüzden aşağıda kart seri noları yoruma alındı
         DECLARE
            d_v_sonuc      NUMBER;
            d_deg_kull     VARCHAR2 (150);
            v_random_sfire VARCHAR2 (500);

            --d_serial_number   wiz_equip.serial_number%TYPE;

            CURSOR cur_ins_upd_sifre  IS
               SELECT degistiren_kullanici
                 FROM mb_abone_sifre
                WHERE account_number = v_uye_no;
         BEGIN
            OPEN cur_ins_upd_sifre;

            FETCH cur_ins_upd_sifre INTO d_deg_kull;

            IF cur_ins_upd_sifre%NOTFOUND OR d_deg_kull = 'SYSTEM' THEN
               --d_serial_number :=
               --   abone_sifre_pack.find_min_sc_serial (v_uye_no);

               --               IF    d_serial_number = v_sc_ekipman_no
               --                  OR d_serial_number IS NOT NULL
               --               THEN
               v_random_sfire := ias_dba.generate_rnd_psw; --5 karakterlik random şifre üretir
               v_random_sfire := digipaket_sifre.encrypt (v_random_sfire);
               abone_sifre_pack.mb_abone_sifre_insert_update (v_uye_no, v_random_sfire, v_random_sfire, 0, 'SYSTEM', 'WEB', d_v_sonuc);

               IF d_v_sonuc = '0' THEN
                  status := 'HATA!!! MB ABONE SIFRE INSERT UPDATE IN wiz_equip_to_abone_insert ';

                  CLOSE cur_ins_upd_sifre;

                  RETURN;
               END IF;
            --END IF;
            END IF;

            CLOSE cur_ins_upd_sifre;
         END;
      END IF;
   END wiz_equip_to_abone_insert;

   ------------------------------------------------------------------
   -- Aboneden düsürülüp depoya atarken veya
   -- depodan depoya aktarilirken de bu fonksiyon çagriliyor.
   PROCEDURE wiz_equip_to_location_insert (ekipman_no          IN     wiz_equip.serial_number%TYPE,
                                           equip_location_code IN     wiz_equip.equip_location_code%TYPE,
                                           work_order_number   IN     wiz_equip.work_order_number%TYPE,
                                           teknisyen_kodu      IN     wiz_equip.technician%TYPE,
                                           accden_dusurme      IN     NUMBER,
                                           old_lokasyon        IN     wiz_equip.equip_location_code%TYPE,
                                           kullanici_kodu      IN     wiz_equip_trx.operator_id%TYPE,
                                           out_trx_tarih          OUT wiz_equip_trx.trx_date%TYPE,
                                           status                 OUT VARCHAR2
                                          ) IS
      v_ekipman_no            wiz_equip.serial_number%TYPE;
      v_equip_location_code   wiz_equip.equip_location_code%TYPE;
      v_kullanici_kodu        wiz_equip_trx.operator_id%TYPE;
      v_manufacturer          wiz_equip.manufacturer%TYPE;
      v_work_order_number     wiz_equip.work_order_number%TYPE;
      v_teknisyen_kodu        wiz_equip.technician%TYPE;
      v_co_kull_kod           co_kullanici.kod%TYPE;
      v_account_number        wiz_equip.account_number%TYPE;
      v_old_lokasyon          wiz_equip.equip_location_code%TYPE;
      v_outlet                wiz_equip.outlet_location%TYPE;
      v_sc_ekipman_no         wiz_equip.serial_number%TYPE;
      v_st_ekipman_no         wiz_equip.serial_number%TYPE;
      v_md_ekipman_no         wiz_equip.serial_number%TYPE;
      v_gca                   VARCHAR2 (255);
      v_converter_type        VARCHAR2 (2);
      v_converter_model       VARCHAR2 (10);
      v_chipset_seri_no       VARCHAR2 (20);
      v_irdetodestekliekipman VARCHAR2 (1);
      v_manufactureruyumlu    VARCHAR2 (1);
      v_tra_id                NUMBER;
      v_ret                   NUMBER (1);
      v_count                 NUMBER;
   BEGIN
      status        := '0';
      out_trx_tarih := TO_DATE ('01.01.0001', 'dd.mm.yyyy');

      IF ekipman_no IS NULL THEN
         status := 'WIZ_EQUIP_TO_LOCATION_INSERT : Ekipman bilgisi dolu olmalidir!';
         RETURN;
      ELSE
         v_ekipman_no := TRIM (ekipman_no);
      END IF;

      IF equip_location_code IS NULL THEN
         status := 'WIZ_EQUIP_TO_LOCATION_INSERT : Teknik Servis Bilgisi Dolu Olmalidir!';

         RETURN;
      ELSE
         v_equip_location_code := TRIM (equip_location_code);
      END IF;

      IF kullanici_kodu IS NULL THEN
         status := 'WIZ_EQUIP_TO_LOCATION_INSERT : Kullanici Bilgisi Dolu Olmalidir!';
         RETURN;
      ELSE
         BEGIN
            SELECT co_kullanici.wiz_operator_id, co_kullanici.kod
              INTO v_kullanici_kodu, v_co_kull_kod
              FROM co_kullanici
             WHERE co_kullanici.wiz_operator_id = kullanici_kodu;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               status := 'WIZ_EQUIP_TO_LOCATION_INSERT : Hatali kullanici kodu ';
               RETURN;
         END;
      END IF;

      IF teknisyen_kodu IS NULL THEN
         v_teknisyen_kodu := NULL;
      ELSE
         v_teknisyen_kodu := TRIM (teknisyen_kodu);
      END IF;

      IF work_order_number IS NULL THEN
         v_work_order_number := 0;
      ELSE
         v_work_order_number := TRIM (work_order_number);
      END IF;

      BEGIN -- ekipman sistemde var mi ? ve boSta mi ?
         SELECT manufacturer, account_number, equip_location_code, TRIM (outlet_location), TRIM (converter_type), TRIM (converter_model)
           INTO v_manufacturer, v_account_number, v_old_lokasyon, v_outlet, v_converter_type, v_converter_model
           FROM wiz_equip
          WHERE serial_number = v_ekipman_no;

         IF (NOT old_lokasyon IS NULL) AND old_lokasyon <> LTRIM (RTRIM (v_old_lokasyon)) THEN
            status := 'WIZ_EQUIP_TO_LOCATION_INSERT : EKIPMAN SU AN FARKLI LOKASYONDA.LÜTFEN KYDI GÜNCELLEYINIZ.';
            RETURN;
         ELSIF v_account_number = 0 AND accden_dusurme = 1 THEN
            status := 'WIZ_EQUIP_TO_LOCATION_INSERT : EKIPMAN ZATEN ABONE ÜZERINDE DEGIL';
            RETURN;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            status := 'WIZ_EQUIP_TO_LOCATION_INSERT : EKIPMAN SISTEMDE YOK';
            RETURN;
      END;

      ------------------------------------------------------
      -- IBX0000950 IRDETO
      -- Kutu ve kart eslesmesinin bozulmasi için siyal gönderimi yapilir
      -- Asagidaki update çekilmeden abone üzerindeki ekipmanlarin degeri alinmali !!
      ekipman_irdeto_desteklimi (v_account_number,
                                 v_outlet,
                                 v_ekipman_no,
                                 v_manufacturer,
                                 v_converter_type,
                                 v_converter_model,
                                 'C',
                                 v_sc_ekipman_no,
                                 v_st_ekipman_no,
                                 v_md_ekipman_no,
                                 v_manufactureruyumlu,
                                 v_irdetodestekliekipman,
                                 status
                                );

      IF status <> '0' THEN
         RETURN;
      END IF;

      IF v_manufactureruyumlu = 'H' THEN
         status := 'Üye üzerinde İrdeto Kart\Modül - Sadece Cyrpto Kutu ile birlikte üyede bırakılamaz. ';
         RETURN;
      END IF;

      IF v_account_number > 0 AND accden_dusurme = 1 THEN
         abone_detay_pack.mb_abone_rating_yetki (v_account_number, v_outlet, 1, 0, v_co_kull_kod, status);

         IF status <> '0' THEN
            status := 'WIZ_EQUIP_TO_LOCATION_INSERT-mb_abone_rating_yetki: ' || status;
            RETURN;
         END IF;
      END IF;

      SELECT SYSDATE INTO out_trx_tarih FROM DUAL;

      UPDATE wiz_equip
         SET converter_id                  = 0,
             channel_map_1                 = 0,
             channel_map_2                 = 0,
             channel_map_3                 = 0,
             channel_map_4                 = 0,
             polled_date                   = out_trx_tarih,
             converter_options             = 0,
             equip_location_code           = v_equip_location_code,
             service_address_id            = 0,
             account_number                = 0,
             outlet_location               = ' ',
             work_order_number             = v_work_order_number,
             technician                    = v_teknisyen_kodu,
             install_date                  = out_trx_tarih,
             ppv_purchase_default_limit    = 0,
             ppv_purchase_current_limit    = 0,
             ppv_purchase_limit_reason     = '  ',
             ppv_purchase_current_used     = 0,
             mpaa_rating_degree            = 0,
             ani_phone_number              = ' ',
             distributor_code              = ' ',
             renewal_frequency             = 0,
             parental_access_code          = ' ',
             ppv_parental_access_code      = ' ',
             wiz_equip.secondary_conv_info = v_co_kull_kod
       WHERE serial_number = v_ekipman_no;

      INSERT INTO wiz_equip_trx (serial_number, manufacturer, work_order_number, account_number, trx_date, operator_id, technician, repair_code, new_location)
           VALUES (v_ekipman_no, v_manufacturer, v_work_order_number, 0, out_trx_tarih, v_kullanici_kodu, v_teknisyen_kodu, '   ', v_equip_location_code);

      -- aboneden düsürme ise sinyal islemleri yapilir
      IF v_account_number > 0 AND accden_dusurme = 1 THEN
         IF v_irdetodestekliekipman = 'E' THEN
            /*--- Evren --- 20110222 --- begin ---*/
            IF v_converter_type = 'SC' THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM mb_abone_ozellik
                WHERE account_number = v_account_number AND (outlet_location = v_outlet OR outlet_location IS NULL) AND abone_ozellik_kodu = 216;

               IF v_count > 0 THEN
                  addressability_pack.dbs_cancel_product (ekipman_no, v_co_kull_kod, 7301, status);

                  IF status <> '0' THEN
                     RETURN;
                  END IF;
               END IF;
            END IF;

            /*--- Evren --- 20110222 --- end ---*/
            IF v_sc_ekipman_no <> '-1' AND v_st_ekipman_no <> '-1' THEN
               NULL;
            -- FALAMUR 22042010
            --               addressability_pack.unpairchip (v_st_ekipman_no,
            --                                               v_sc_ekipman_no,
            --                                               v_co_kull_kod,
            --                                               status
            --                                              );

            --               IF NVL (status, '0') <> '0'
            --               THEN
            --                  RETURN;
            --               END IF;
            END IF;
         END IF;

         -- Karta sinyal gidemiyorsa filter product islemi yapamaz.
         IF     ekipman_durumu_pack.dummy_mi (v_sc_ekipman_no) = 0
            AND ekipman_durumu_pack.kill_mi (v_sc_ekipman_no) = 0
            AND ekipman_durumu_pack.sinyal_gon_engellenmis_mi (v_sc_ekipman_no) = 0 THEN
            -- Kart degisikliginde de, kutu degisikliginde de SC üzerinde GCA, TMS degisikligi gerekebilir.
            IF v_sc_ekipman_no NOT IN ('-1', '-2') THEN
               dbs_addr_reqs_pack.find_set_gca (v_sc_ekipman_no, v_co_kull_kod, status, ppvr => v_irdetodestekliekipman);
            END IF;
         END IF;
      END IF;
   END wiz_equip_to_location_insert;

   /*bozturkmen account, outlet ve ekipman tipi ile matrix id yi almak için*/
   PROCEDURE get_ekipman_tip_matrix (in_account_number IN     NUMBER,
                                     in_outlet         IN     VARCHAR2,
                                     in_ekipman_tipi   IN     VARCHAR2,
                                     o_eq_tip_matrix      OUT NUMBER,
                                     o_durum              OUT VARCHAR2
                                    ) IS
      v_serial eq_ekipman.serial_number%TYPE;
   BEGIN
      v_serial := get_ekipman_serial (in_account_number, in_outlet, in_ekipman_tipi);

      IF v_serial IS NOT NULL THEN
         get_ekipman_tip_matrix (v_serial, o_eq_tip_matrix, o_durum);
      ELSE
         o_durum         := 'get_ekipman_tip_matrix : Ekipman bulunamadı.';
         o_eq_tip_matrix := NULL;
      END IF;
   END;

   /*--- evren --- 20100511 --- begin ---*/
   PROCEDURE get_ekipman_tip_matrix (i_serial_number IN VARCHAR2, o_eq_tip_matrix OUT NUMBER, o_durum OUT VARCHAR2) IS
   BEGIN
      SELECT y.eq_ekipman_tip_matrix_id
        INTO o_eq_tip_matrix
        FROM wiz_equip x,
             eq_ekipman_tip_matrix y
       WHERE     TRIM (x.manufacturer) = TRIM (y.manufacturer)
             AND TRIM (x.converter_type) = TRIM (y.converter_type)
             AND TRIM (x.converter_model) = TRIM (y.converter_model)
             AND x.serial_number = i_serial_number;

      o_durum := '0';
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         BEGIN
            SELECT y.eq_ekipman_tip_matrix_id
              INTO o_eq_tip_matrix
              FROM eq_ekipman x,
                   eq_ekipman_tip_matrix y
             WHERE     TRIM (x.ekipman_tipi) = TRIM (y.converter_type)
                   AND NVL (TRIM (x.ekipman_modul_tipi), -1) = NVL (TRIM (y.converter_model), -1)
                   AND x.serial_number = i_serial_number;

            o_durum := '0';
         EXCEPTION
            WHEN OTHERS THEN
               o_durum := 'Ekipman tanimli degil : ' || i_serial_number || SQLERRM;
         END;
   END;

   /*--- evren --- 20100511 --- end ---*/
   PROCEDURE telefon_ekipman_islemleri (iislem_tipi                IN     VARCHAR2,
                                        ialt_islem_tipi            IN     VARCHAR2,
                                        iotorizasyon_no            IN     its_servis.kayit_no%TYPE,
                                        ilg_teknik_servis_sifre_id IN     lg_teknik_servis_sifre.id%TYPE,
                                        its_no                     IN     lg_ekipman.sales_agent_code%TYPE,
                                        istb_depo_kodu             IN     lg_ekipman.depoya%TYPE,
                                        imd_depo_kodu              IN     lg_ekipman.depoya%TYPE,
                                        isc_depo_kodu              IN     lg_ekipman.depoya%TYPE,
                                        iuye_no                    IN     wiz_equip.account_number%TYPE,
                                        ioutlet_location           IN     wiz_equip.outlet_location%TYPE,
                                        istb_serial_number         IN     wiz_equip.serial_number%TYPE,
                                        imd_serial_number          IN     eq_ekipman.serial_number%TYPE,
                                        isc_serial_number          IN     wiz_equip.serial_number%TYPE,
                                        inew_stb_serial_number     IN     wiz_equip.serial_number%TYPE,
                                        inew_md_serial_number      IN     eq_ekipman.serial_number%TYPE,
                                        inew_sc_serial_number      IN     wiz_equip.serial_number%TYPE,
                                        istb_kayip                 IN     CHAR,
                                        imd_kayip                  IN     CHAR,
                                        isc_kayip                  IN     CHAR,
                                        its_form_no                IN     lg_ekipman.ts_form_no%TYPE,
                                        in_aciklama                IN     lg_ekipman.aciklama%TYPE,
                                        igiren_kullanici           IN     co_kullanici.kod%TYPE,
                                        iok                        IN     VARCHAR2 := '0:E',
                                        odurum                        OUT VARCHAR2,
                                        oproc_name                    OUT VARCHAR2
                                       ) IS
      --iOK = '0:E' hersey ok default
      --iOK = '1:E' 'ÜYENIN OUTLETINDE BASKA BIR EKIPMAN BULUNMAKTADIR.'||CHR(10)||CHR(13)||'BU EKIPMANIN INVALID DEPOSUNA ATILMASINI ONAYLIYOR MUSUNUZ?';
      --iOK = '2:E' 'ESKI EKIPMAN ÜYEYE VERILIP TEKRAR BELIRTILEN DEPOYA ATILACAKTIR.'||CHR(10)||CHR(13)||'BU ISLEMLERI ONAYLIYOR MUSUNUZ?';
      --iOK = '3:E' ekipman eklemede hata olustu devam edilsin mi
      --ESKI EKIPMAN ÜYEYE VERILEMEDI.'||CHR(10)||CHR(13)||odurum||CHR(10)||CHR(13)||'DEVAM ETMEK ISTIYOR MUSUNUZ?';
      v_error_type         NUMBER (1);
      v_error_code         VARCHAR2 (10);
      v_error_text         VARCHAR2 (512);
      v_service_address_id NUMBER (10);
      ois_emri             NUMBER (10);
      v_taa_uyari          VARCHAR2 (512);
      v_reason_code        lg_ekipman.depoya%TYPE := 'YTL';
      vekipman_modul_tipi  NUMBER;
      oeq_ekipman_id       NUMBER;
      v_ekipman_ekle_st    BOOLEAN;
      v_ekipman_ekle_md    BOOLEAN;
      v_ekipman_tipi       NUMBER;
   BEGIN
      odurum            := 'FAILED';
      oproc_name        := 'TELEFON_EKIPMAN_ISLEMLERI';
      v_ekipman_ekle_st := FALSE;
      v_ekipman_ekle_md := FALSE;

      IF TRIM (iok) IS NULL THEN
         odurum     := 'GIRIS PARAMETRELERI HATALI PARAMETREi:OK.';
         oproc_name := 'TELEFON_EKIPMAN_ISLEMLERI';
         RETURN;
      END IF;

      IF TRIM (iislem_tipi) = 'EKIPMAN_DEGISIM' THEN
         IF ialt_islem_tipi = 'SC_DEGISIM' THEN
            ekipman_pack.telefon_ekipman_degisim (ialt_islem_tipi,
                                                  iotorizasyon_no,
                                                  ilg_teknik_servis_sifre_id,
                                                  its_no,
                                                  isc_depo_kodu,
                                                  iuye_no,
                                                  ioutlet_location,
                                                  isc_serial_number,
                                                  inew_sc_serial_number,
                                                  isc_kayip,
                                                  its_form_no,
                                                  in_aciklama,
                                                  igiren_kullanici,
                                                  iok,
                                                  odurum,
                                                  oproc_name
                                                 );
         ELSIF ialt_islem_tipi = 'STB_DEGISIM' THEN
            ekipman_pack.telefon_ekipman_degisim (ialt_islem_tipi,
                                                  iotorizasyon_no,
                                                  ilg_teknik_servis_sifre_id,
                                                  its_no,
                                                  istb_depo_kodu,
                                                  iuye_no,
                                                  ioutlet_location,
                                                  istb_serial_number,
                                                  inew_stb_serial_number,
                                                  istb_kayip,
                                                  its_form_no,
                                                  in_aciklama,
                                                  igiren_kullanici,
                                                  iok,
                                                  odurum,
                                                  oproc_name
                                                 );
         ELSIF ialt_islem_tipi = 'MD_DEGISIM' OR ialt_islem_tipi = 'KEN_DEGISIM' -- HDD ken degisim gibi calisiyor
                                                                                THEN
            ekipman_pack.telefon_ekipman_degisim (ialt_islem_tipi,
                                                  iotorizasyon_no,
                                                  ilg_teknik_servis_sifre_id,
                                                  its_no,
                                                  imd_depo_kodu,
                                                  iuye_no,
                                                  ioutlet_location,
                                                  imd_serial_number,
                                                  inew_md_serial_number,
                                                  imd_kayip,
                                                  its_form_no,
                                                  in_aciklama,
                                                  igiren_kullanici,
                                                  iok,
                                                  odurum,
                                                  oproc_name
                                                 );
         ELSIF ialt_islem_tipi = 'STB_MD_DEGISIM' THEN
            IF TRIM (inew_md_serial_number) IS NOT NULL THEN
               -- yeni modül dolu ise ekle
               SELECT TRIM (ekipman_modul_tipi)
                 INTO vekipman_modul_tipi
                 FROM eq_ekipman
                WHERE serial_number = inew_md_serial_number;
            END IF;

            IF TRIM (isc_serial_number) IS NULL OR TRIM (inew_sc_serial_number) IS NULL THEN
               odurum     := 'ESKI ve YENI SC EKIPMAN NOLARI BOS OLAMAZ.';
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            END IF;

            IF TRIM (inew_stb_serial_number) IS NULL AND TRIM (inew_md_serial_number) IS NULL THEN
               odurum     := 'YENI STB veya MODUL EKIPMAN BILGISINDEN EN AZ BIRI DOLU OLMALIDIR.';
               oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
               RETURN;
            END IF;

            BEGIN
               SELECT service_address_id
                 INTO v_service_address_id
                 FROM wiz_customer_hp_life
                WHERE account_number = iuye_no;
            EXCEPTION
               WHEN OTHERS THEN
                  odurum     := 'ÜYE KAYDI BULUNAMADI.';
                  oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
                  RETURN;
            END;

            IF TRIM (istb_serial_number) IS NULL AND TRIM (imd_serial_number) IS NULL THEN
               NULL;
               -- Kartları değiştir.
               ekipman_pack.telefon_ekipman_degisim (ialt_islem_tipi,
                                                     iotorizasyon_no,
                                                     ilg_teknik_servis_sifre_id,
                                                     its_no,
                                                     isc_depo_kodu,
                                                     iuye_no,
                                                     ioutlet_location,
                                                     isc_serial_number,
                                                     inew_sc_serial_number,
                                                     isc_kayip,
                                                     its_form_no,
                                                     in_aciklama,
                                                     igiren_kullanici,
                                                     iok,
                                                     odurum,
                                                     oproc_name
                                                    );

               IF odurum <> '0' THEN
                  RETURN;
               END IF;

               IF TRIM (inew_md_serial_number) IS NOT NULL THEN
                  eq_ekipman_pack.eq_ekipman_ekle (iuye_no,
                                                   v_reason_code,
                                                   ioutlet_location,
                                                   248,
                                                   NULL,
                                                   vekipman_modul_tipi,
                                                   inew_md_serial_number,
                                                   its_no, --> i_sales_agent_code
                                                   SYSDATE, --> i_kurulum_tarihi
                                                   in_aciklama, --> i_aciklama
                                                   igiren_kullanici, --> i_kisi
                                                   SYSDATE, --> i_islem_tarihi
                                                   'H', --> i_kontratsiz_aktifleme
                                                   'H', --> i_otel_mi
                                                   NULL, --> i_sozlesme
                                                   ilg_teknik_servis_sifre_id,
                                                   iotorizasyon_no,
                                                   its_form_no,
                                                   oeq_ekipman_id,
                                                   odurum
                                                  );
                  v_ekipman_ekle_md := TRUE;

                  IF odurum <> '0' THEN
                     RETURN;
                  END IF;
               END IF;

               -- Kutu varsa kutu Ekle
               IF TRIM (inew_stb_serial_number) IS NOT NULL THEN
                  ekipman_pack.ekipman_ekle (iuye_no,
                                             inew_stb_serial_number,
                                             ioutlet_location,
                                             its_no,
                                             its_form_no,
                                             v_reason_code, --YTS TELEFON
                                             NULL,
                                             v_service_address_id,
                                             'N',
                                             'N',
                                             igiren_kullanici,
                                             iotorizasyon_no,
                                             ilg_teknik_servis_sifre_id,
                                             NULL, --sozlesme_no
                                             in_aciklama,
                                             odurum,
                                             oproc_name,
                                             ois_emri,
                                             v_error_type,
                                             v_error_code,
                                             v_error_text
                                            );
                  v_ekipman_ekle_st := TRUE;

                  IF odurum <> '0' THEN
                     RETURN;
                  END IF;
               END IF;
            ELSIF    (TRIM (istb_serial_number) IS NOT NULL AND TRIM (inew_stb_serial_number) IS NULL)
                  OR (TRIM (imd_serial_number) IS NOT NULL AND TRIM (inew_md_serial_number) IS NULL) THEN
               IF TRIM (istb_serial_number) IS NOT NULL THEN
                  -- stb boş degilse stb çıkar
                  ekipman_pack.ekipman_cikar (iuye_no,
                                              istb_serial_number,
                                              ioutlet_location,
                                              its_no,
                                              its_form_no,
                                              v_reason_code,
                                              istb_depo_kodu,
                                              v_service_address_id,
                                              igiren_kullanici,
                                              iotorizasyon_no,
                                              ilg_teknik_servis_sifre_id,
                                              in_aciklama,
                                              odurum,
                                              v_taa_uyari,
                                              oproc_name,
                                              ois_emri,
                                              v_error_type,
                                              v_error_code,
                                              v_error_text
                                             );

                  IF odurum <> '0' THEN
                     RETURN;
                  END IF;
               END IF;

               -- md boş değilse md çıkar
               IF TRIM (imd_serial_number) IS NOT NULL THEN
                  eq_ekipman_pack.eq_ekipman_cikar (iuye_no,
                                                    imd_depo_kodu,
                                                    v_reason_code,
                                                    ioutlet_location,
                                                    248,
                                                    imd_serial_number,
                                                    its_no,
                                                    in_aciklama,
                                                    igiren_kullanici,
                                                    SYSDATE,
                                                    ilg_teknik_servis_sifre_id,
                                                    iotorizasyon_no,
                                                    its_form_no,
                                                    odurum,
                                                    v_taa_uyari
                                                   );

                  IF odurum <> '0' THEN
                     RETURN;
                  END IF;
               END IF;

               -- sc değiştir
               ekipman_pack.telefon_ekipman_degisim (ialt_islem_tipi,
                                                     iotorizasyon_no,
                                                     ilg_teknik_servis_sifre_id,
                                                     its_no,
                                                     isc_depo_kodu,
                                                     iuye_no,
                                                     ioutlet_location,
                                                     isc_serial_number,
                                                     inew_sc_serial_number,
                                                     isc_kayip,
                                                     its_form_no,
                                                     in_aciklama,
                                                     igiren_kullanici,
                                                     iok,
                                                     odurum,
                                                     oproc_name
                                                    );

               IF odurum <> '0' THEN
                  RETURN;
               END IF;

               IF TRIM (inew_md_serial_number) IS NOT NULL THEN
                  eq_ekipman_pack.eq_ekipman_ekle (iuye_no,
                                                   v_reason_code,
                                                   ioutlet_location,
                                                   248,
                                                   NULL,
                                                   vekipman_modul_tipi,
                                                   inew_md_serial_number,
                                                   its_no, --> i_sales_agent_code
                                                   SYSDATE, --> i_kurulum_tarihi
                                                   in_aciklama, --> i_aciklama
                                                   igiren_kullanici, --> i_kisi
                                                   SYSDATE, --> i_islem_tarihi
                                                   'H', --> i_kontratsiz_aktifleme
                                                   'H', --> i_otel_mi
                                                   NULL, --> i_sozlesme
                                                   ilg_teknik_servis_sifre_id,
                                                   iotorizasyon_no,
                                                   its_form_no,
                                                   oeq_ekipman_id,
                                                   odurum
                                                  );
                  v_ekipman_ekle_md := TRUE;

                  IF odurum <> '0' THEN
                     RETURN;
                  END IF;
               END IF;

               -- yeni kutu dolu ise kutuyu ekle
               IF TRIM (inew_stb_serial_number) IS NOT NULL THEN
                  ekipman_pack.ekipman_ekle (iuye_no,
                                             inew_stb_serial_number,
                                             ioutlet_location,
                                             its_no,
                                             its_form_no,
                                             v_reason_code, --YTS TELEFON
                                             NULL,
                                             v_service_address_id,
                                             'N',
                                             'N',
                                             igiren_kullanici,
                                             iotorizasyon_no,
                                             ilg_teknik_servis_sifre_id,
                                             NULL, --sozlesme_no
                                             in_aciklama,
                                             odurum,
                                             oproc_name,
                                             ois_emri,
                                             v_error_type,
                                             v_error_code,
                                             v_error_text
                                            );
                  v_ekipman_ekle_st := TRUE;

                  IF odurum <> '0' THEN
                     RETURN;
                  END IF;
               END IF;
            ELSE
               -- kartı çıkar
               ekipman_pack.ekipman_cikar (iuye_no,
                                           isc_serial_number,
                                           ioutlet_location,
                                           its_no,
                                           its_form_no,
                                           v_reason_code,
                                           isc_depo_kodu,
                                           v_service_address_id,
                                           igiren_kullanici,
                                           iotorizasyon_no,
                                           ilg_teknik_servis_sifre_id,
                                           in_aciklama,
                                           odurum,
                                           v_taa_uyari,
                                           oproc_name,
                                           ois_emri,
                                           v_error_type,
                                           v_error_code,
                                           v_error_text
                                          );

               IF odurum <> '0' THEN
                  RETURN;
               END IF;

               IF TRIM (istb_serial_number) IS NOT NULL THEN
                  IF TRIM (inew_stb_serial_number) IS NOT NULL THEN
                     -- STB degistir
                     ekipman_pack.telefon_ekipman_degisim (ialt_islem_tipi,
                                                           iotorizasyon_no,
                                                           ilg_teknik_servis_sifre_id,
                                                           its_no,
                                                           istb_depo_kodu,
                                                           iuye_no,
                                                           ioutlet_location,
                                                           istb_serial_number,
                                                           inew_stb_serial_number,
                                                           istb_kayip,
                                                           its_form_no,
                                                           in_aciklama,
                                                           igiren_kullanici,
                                                           iok,
                                                           odurum,
                                                           oproc_name
                                                          );

                     IF odurum <> '0' THEN
                        RETURN;
                     END IF;
                  ELSE
                     --  stb çıkar
                     ekipman_pack.ekipman_cikar (iuye_no,
                                                 istb_serial_number,
                                                 ioutlet_location,
                                                 its_no,
                                                 its_form_no,
                                                 v_reason_code,
                                                 istb_depo_kodu,
                                                 v_service_address_id,
                                                 igiren_kullanici,
                                                 iotorizasyon_no,
                                                 ilg_teknik_servis_sifre_id,
                                                 in_aciklama,
                                                 odurum,
                                                 v_taa_uyari,
                                                 oproc_name,
                                                 ois_emri,
                                                 v_error_type,
                                                 v_error_code,
                                                 v_error_text
                                                );

                     IF odurum <> '0' THEN
                        RETURN;
                     END IF;
                  END IF;
               END IF;

               IF TRIM (imd_serial_number) IS NOT NULL THEN
                  IF TRIM (inew_md_serial_number) IS NOT NULL THEN
                     -- md degistir
                     ekipman_pack.telefon_ekipman_degisim (ialt_islem_tipi,
                                                           iotorizasyon_no,
                                                           ilg_teknik_servis_sifre_id,
                                                           its_no,
                                                           imd_depo_kodu,
                                                           iuye_no,
                                                           ioutlet_location,
                                                           imd_serial_number,
                                                           inew_md_serial_number,
                                                           imd_kayip,
                                                           its_form_no,
                                                           in_aciklama,
                                                           igiren_kullanici,
                                                           iok,
                                                           odurum,
                                                           oproc_name
                                                          );

                     IF odurum <> '0' THEN
                        RETURN;
                     END IF;
                  ELSE
                     --  md çıkar
                     eq_ekipman_pack.eq_ekipman_cikar (iuye_no,
                                                       imd_depo_kodu,
                                                       v_reason_code,
                                                       ioutlet_location,
                                                       248,
                                                       imd_serial_number,
                                                       its_no,
                                                       in_aciklama,
                                                       igiren_kullanici,
                                                       SYSDATE,
                                                       ilg_teknik_servis_sifre_id,
                                                       iotorizasyon_no,
                                                       its_form_no,
                                                       odurum,
                                                       v_taa_uyari
                                                      );

                     IF odurum <> '0' THEN
                        RETURN;
                     END IF;
                  END IF;
               END IF;

               IF TRIM (imd_serial_number) IS NULL AND TRIM (inew_md_serial_number) IS NOT NULL THEN
                  IF TRIM (inew_md_serial_number) IS NOT NULL THEN
                     eq_ekipman_pack.eq_ekipman_ekle (iuye_no,
                                                      v_reason_code,
                                                      ioutlet_location,
                                                      248,
                                                      NULL,
                                                      vekipman_modul_tipi,
                                                      inew_md_serial_number,
                                                      its_no, --> i_sales_agent_code
                                                      SYSDATE, --> i_kurulum_tarihi
                                                      in_aciklama, --> i_aciklama
                                                      igiren_kullanici, --> i_kisi
                                                      SYSDATE, --> i_islem_tarihi
                                                      'H', --> i_kontratsiz_aktifleme
                                                      'H', --> i_otel_mi
                                                      NULL, --> i_sozlesme
                                                      ilg_teknik_servis_sifre_id,
                                                      iotorizasyon_no,
                                                      its_form_no,
                                                      oeq_ekipman_id,
                                                      odurum
                                                     );
                     v_ekipman_ekle_md := TRUE;

                     IF odurum <> '0' THEN
                        RETURN;
                     END IF;
                  END IF;
               END IF;

               IF TRIM (istb_serial_number) IS NULL AND TRIM (inew_stb_serial_number) IS NOT NULL THEN
                  --ST EKLE
                  ekipman_pack.ekipman_ekle (iuye_no,
                                             inew_stb_serial_number,
                                             ioutlet_location,
                                             its_no,
                                             its_form_no,
                                             v_reason_code, --YTS TELEFON
                                             NULL,
                                             v_service_address_id,
                                             'N',
                                             'N',
                                             igiren_kullanici,
                                             iotorizasyon_no,
                                             ilg_teknik_servis_sifre_id,
                                             NULL, --sozlesme_no
                                             in_aciklama,
                                             odurum,
                                             oproc_name,
                                             ois_emri,
                                             v_error_type,
                                             v_error_code,
                                             v_error_text
                                            );
                  v_ekipman_ekle_st := TRUE;

                  IF odurum <> '0' THEN
                     RETURN;
                  END IF;
               END IF;

               -- Kartı Ekle
               ekipman_pack.ekipman_ekle (iuye_no,
                                          inew_sc_serial_number,
                                          ioutlet_location,
                                          its_no,
                                          its_form_no,
                                          v_reason_code, --YTS TELEFON
                                          NULL,
                                          v_service_address_id,
                                          'N',
                                          'N',
                                          igiren_kullanici,
                                          iotorizasyon_no,
                                          ilg_teknik_servis_sifre_id,
                                          NULL, --sozlesme_no
                                          in_aciklama,
                                          odurum,
                                          oproc_name,
                                          ois_emri,
                                          v_error_type,
                                          v_error_code,
                                          v_error_text
                                         );

               IF odurum <> '0' THEN
                  RETURN;
               END IF;
            END IF;
         ELSE
            odurum     := 'HATALI ALT ISLEM KODU.';
            oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
            RETURN;
         END IF;

         -- Modul veya kutu degisim yapılmadan eklenmiş ise o zaman sahiplik işlemleri burada yapılıyor.
         IF v_ekipman_ekle_st = TRUE OR v_ekipman_ekle_md = TRUE THEN
            DECLARE
               l_franchise_code        wiz_customer_hp_life.franchise_code%TYPE;
               l_hp_cluster            wiz_customer_hp_life.hp_cluster%TYPE;
               l_count                 NUMBER;
               l_error_text            VARCHAR2 (200);
               o_ekipman_tip_matrix_id NUMBER;
            BEGIN
               SELECT franchise_code, hp_cluster
                 INTO l_franchise_code, l_hp_cluster
                 FROM wiz_customer_hp_life
                WHERE account_number = iuye_no;

               IF l_franchise_code IN ('F01', 'F02') AND l_hp_cluster IN ('LG', 'VS') THEN
                  IF v_ekipman_ekle_st = TRUE THEN
                     SELECT COUNT (1)
                       INTO l_count
                       FROM eq_ekipman_sahibi_kim
                      WHERE serial_number = inew_stb_serial_number AND kayit_iptal = 'H' AND ekipman_sahibi_tipi = 1;

                     get_ekipman_tip_matrix (inew_stb_serial_number, o_ekipman_tip_matrix_id, odurum);

                     IF odurum <> '0' THEN
                        oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
                        RETURN;
                     END IF;

                     IF l_count = 0 THEN
                        ekipman_pack.eq_ekipman_sahibi_kim_ins_upd (inew_stb_serial_number,
                                                                    iuye_no,
                                                                    ioutlet_location,
                                                                    247,
                                                                    NULL,
                                                                    'EDS',
                                                                    1,
                                                                    'EKIPMAN DEGISIMI OTOMATIK GECICI SAHIPLIK',
                                                                    NULL,
                                                                    'H',
                                                                    'SYSTEM',
                                                                    NULL,
                                                                    dbs_sabit ('BRAND_DEGISIKLIGI_OTOMATIK_GECICI_SAHIPLIK'),
                                                                    its_no, --'vsales_agent_code,
                                                                    o_ekipman_tip_matrix_id,
                                                                    l_error_text,
                                                                    odurum,
                                                                    'H'
                                                                   );

                        IF odurum <> '0' THEN
                           oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
                           RETURN;
                        END IF;
                     END IF;
                  END IF;

                  IF v_ekipman_ekle_md = TRUE THEN
                     SELECT COUNT (1)
                       INTO l_count
                       FROM eq_ekipman_sahibi_kim
                      WHERE serial_number = inew_md_serial_number AND kayit_iptal = 'H' AND ekipman_sahibi_tipi = 1;

                     get_ekipman_tip_matrix (inew_md_serial_number, o_ekipman_tip_matrix_id, odurum);

                     IF odurum <> '0' THEN
                        oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
                        RETURN;
                     END IF;

                     IF l_count = 0 THEN
                        ekipman_pack.eq_ekipman_sahibi_kim_ins_upd (inew_md_serial_number,
                                                                    iuye_no,
                                                                    ioutlet_location,
                                                                    248,
                                                                    NULL,
                                                                    'EDS',
                                                                    1,
                                                                    'EKIPMAN DEGISIMI OTOMATIK GECICI SAHIPLIK',
                                                                    NULL,
                                                                    'H',
                                                                    'SYSTEM',
                                                                    NULL,
                                                                    dbs_sabit ('BRAND_DEGISIKLIGI_OTOMATIK_GECICI_SAHIPLIK'),
                                                                    its_no, --'vsales_agent_code,
                                                                    o_ekipman_tip_matrix_id,
                                                                    l_error_text,
                                                                    odurum,
                                                                    'H'
                                                                   );

                        IF odurum <> '0' THEN
                           oproc_name := 'TELEFON_EKIPMAN_DEGISIM';
                           RETURN;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END;
         END IF;
      ELSIF TRIM (iislem_tipi) = 'EKIPMAN_IADE' THEN
         ekipman_pack.telefon_ekipman_iade (iotorizasyon_no,
                                            ilg_teknik_servis_sifre_id,
                                            its_no,
                                            istb_depo_kodu,
                                            imd_depo_kodu,
                                            isc_depo_kodu,
                                            iuye_no,
                                            ioutlet_location,
                                            istb_serial_number,
                                            imd_serial_number,
                                            isc_serial_number,
                                            istb_kayip,
                                            imd_kayip,
                                            isc_kayip,
                                            its_form_no,
                                            in_aciklama,
                                            igiren_kullanici,
                                            iok,
                                            odurum,
                                            oproc_name
                                           );
      ELSIF TRIM (iislem_tipi) = 'EKIPMAN_TESLIM' THEN
         IF ialt_islem_tipi = 'MD_HDD_TESLIM' THEN
            IF inew_md_serial_number IS NOT NULL THEN
               SELECT TRIM (ekipman_modul_tipi), ekipman_tipi
                 INTO vekipman_modul_tipi, v_ekipman_tipi
                 FROM eq_ekipman
                WHERE serial_number = inew_md_serial_number;
            ELSE
               SELECT TRIM (ekipman_modul_tipi), ekipman_tipi
                 INTO vekipman_modul_tipi, v_ekipman_tipi
                 FROM eq_ekipman
                WHERE serial_number = imd_serial_number;
            END IF;

            -- HARDDISK ICIN TSF FORMUNDAN EKIPMAN TESLIM ISLEMI YAPTIRAN KOD PARCASI
            -- OZGUR ARSLAN
            eq_ekipman_pack.eq_ekipman_ekle (iuye_no,
                                             v_reason_code,
                                             ioutlet_location,
                                             v_ekipman_tipi,
                                             NULL,
                                             vekipman_modul_tipi,
                                             NVL (inew_md_serial_number, imd_serial_number),
                                             its_no, --> i_sales_agent_code
                                             SYSDATE, --> i_kurulum_tarihi
                                             in_aciklama, --> i_aciklama
                                             igiren_kullanici, --> i_kisi
                                             SYSDATE, --> i_islem_tarihi
                                             'H', --> i_kontratsiz_aktifleme
                                             'H', --> i_otel_mi
                                             NULL, --> i_sozlesme
                                             ilg_teknik_servis_sifre_id,
                                             iotorizasyon_no,
                                             its_form_no,
                                             oeq_ekipman_id,
                                             odurum
                                            );
            v_ekipman_ekle_md := TRUE;
         END IF;

         IF odurum <> '0' THEN
            RETURN;
         END IF;
      ELSE
         odurum     := 'ISLEM TIPI HATALI.';
         oproc_name := 'TELEFON_EKIPMAN_ISLEMLERI';
         RETURN;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         odurum     := SQLERRM;
         oproc_name := 'TELEFON_EKIPMAN_ISLEMLERI';
         RETURN;
   END;

   PROCEDURE valid_depo_lokasyon (idepo_lokasyonu            IN     wiz_equip_location_codes.equip_location_code%TYPE,
                                  odescr                        OUT wiz_equip_location_codes.descr%TYPE,
                                  oassignable                   OUT wiz_equip_location_codes.assignable%TYPE,
                                  oequip_location_group_code    OUT wiz_equip_location_codes.equip_location_group_code%TYPE,
                                  durum                         OUT VARCHAR2
                                 ) IS
      v_descr                     wiz_equip_location_codes.descr%TYPE;
      v_assignable                wiz_equip_location_codes.assignable%TYPE;
      v_equip_location_group_code wiz_equip_location_codes.equip_location_group_code%TYPE;

      CURSOR depo_cur  IS
         SELECT descr, assignable, wiz_equip_location_codes.equip_location_group_code
           FROM wiz_equip_location_codes,
                bt_bayi_teknik_servis
          WHERE     bt_bayi_teknik_servis.sales_agent_code(+) = wiz_equip_location_codes.employee_code
                AND wiz_equip_location_codes.equip_location_group_code <> (SELECT deger
                                                                             FROM pa_sabitler
                                                                            WHERE adi = 'EKIPMAN_DEPO_LOKASYONU_ATILAMAZ')
                AND equip_location_code = idepo_lokasyonu;
   BEGIN
      durum := 'DEPO KODU BULUNAMADI';

      IF LTRIM (idepo_lokasyonu) IS NULL THEN
         durum := 'DEPO KODU DOLU OLMALIDIR';
      ELSE
         OPEN depo_cur;

         LOOP
            FETCH depo_cur INTO v_descr, v_assignable, v_equip_location_group_code;

            EXIT WHEN depo_cur%NOTFOUND;
            odescr                     := v_descr;
            oassignable                := v_assignable;
            oequip_location_group_code := v_equip_location_group_code;
            durum                      := '0';

            CLOSE depo_cur;

            RETURN;
         END LOOP;

         CLOSE depo_cur;
      END IF;
   END valid_depo_lokasyon;

   PROCEDURE kategori_yetki_var_mi (igiren_kullanici IN     co_kullanici.kod%TYPE,
                                    idepo            IN     bt_depo_kategori_yetki.kod%TYPE,
                                    idepoya          IN     bt_depo_kategori_yetki.kod%TYPE,
                                    iislem           IN     bt_depo_kategori_yetki.islem%TYPE,
                                    durum               OUT VARCHAR2
                                   ) IS
      CURSOR depo_cur  IS
         SELECT dy.ust_depo_kod, dy.depo_kod, dy.yetki_grubu
           FROM bt_depo_kategori_yetki dy
          WHERE dy.kod = TRIM (idepo) AND dy.islem = TRIM (iislem) AND dy.depo_kod IS NULL AND dy.listeden_gizle = 'H';

      CURSOR xdepo_cur  IS
         SELECT dy.ust_depo_kod, dy.depo_kod, dy.yetki_grubu
           FROM bt_depo_kategori_yetki dy
          WHERE dy.kod = TRIM (idepo) AND dy.islem = TRIM (iislem) AND dy.depo_kod = TRIM (idepoya) AND dy.depo_kod IS NOT NULL AND dy.listeden_gizle = 'H';

      CURSOR ust_cur (p_depo bt_depo_kategori_yetki.ust_depo_kod%TYPE) IS
         SELECT ust_depo_kod, yetki_grubu
           FROM bt_depo_kategori_yetki dy
          WHERE dy.ust_depo_kod = TRIM (p_depo) AND dy.islem = TRIM (iislem) AND dy.listeden_gizle = 'H';

      ust_rec     ust_cur%ROWTYPE;
      depo_rec    depo_cur%ROWTYPE;
      xdepo_rec   xdepo_cur%ROWTYPE;
      v_count     NUMBER (6) := 0;
      v_ust_depo  wiz_equip_location_codes.ust_depo_kod%TYPE;
      v_str_yetki co_yetki_tanim.yetki_adi%TYPE;
      v_istip_ctr NUMBER;
   BEGIN
      durum       := 'YOK';
      v_str_yetki := 'EKIPMAN_DEPO_KATEGORI_YETKI_';

      -----------[Islem tipi kontrolü]----------------------
      SELECT COUNT (*)
        INTO v_istip_ctr
        FROM pa_sabitler
       WHERE deger = TRIM (iislem) AND SUBSTR (adi, 1, 20) = 'KATEGORI_YETKI_ISLEM';

      IF v_istip_ctr = 0 THEN
         durum := 'GIRILEN ISLEM TIPI TANIMLI DEGIL !';
         RETURN;
      END IF;

      BEGIN
         SELECT ust_depo_kod
           INTO v_ust_depo
           FROM wiz_equip_location_codes
          WHERE equip_location_code = TRIM (idepo);
      EXCEPTION
         WHEN OTHERS THEN
            durum := SQLERRM;
            RETURN;
      END;

      --------------------------------------
      --üye islemleri
      --------------------------------------
      IF TRIM (idepoya) IS NULL THEN
         OPEN depo_cur;

         FETCH depo_cur INTO depo_rec;

         IF depo_cur%NOTFOUND THEN
            IF TRIM (v_ust_depo) IS NULL THEN
               durum := 'VAR';
               RETURN;
            ELSE
               --yetki tanimlanmamissa üst koda bak
               -------------------------------------------------------
               OPEN ust_cur (v_ust_depo);

               FETCH ust_cur INTO ust_rec;

               IF ust_cur%NOTFOUND THEN
                  durum := 'VAR';
                  RETURN;
               ELSE
                  v_str_yetki := v_str_yetki || ust_rec.yetki_grubu;
                  durum       := yetki_pack.yetkisi_varmi (igiren_kullanici, v_str_yetki);

                  IF durum = '0' THEN
                     durum := 'YOK';
                  ELSE
                     durum := 'VAR';
                  END IF;

                  RETURN;
               END IF;

               CLOSE ust_cur;
            END IF;
         --yetki tanimlanmissa bu koda ait yetki var mi bak
         -------------------------------------------------------
         ELSE
            v_str_yetki := v_str_yetki || depo_rec.yetki_grubu;
            durum       := yetki_pack.yetkisi_varmi (igiren_kullanici, v_str_yetki);

            IF durum = '0' THEN
               durum := 'YOK';
            ELSE
               durum := 'VAR';
            END IF;

            RETURN;
         END IF;

         CLOSE depo_cur;
      ELSE
         ------------------------------------------------------------
         --depo islemleri
         ------------------------------------------------------------
         OPEN xdepo_cur;

         FETCH xdepo_cur INTO xdepo_rec;

         --depoya kodu dolu yetki tanimlanmis mi bak
         -------------------------------------------------------
         IF xdepo_cur%NOTFOUND THEN
            --yetki tanimlanmamissa depo kodu bos olanlar içinde yetki bak
            --------------------------------------------------------------
            OPEN depo_cur;

            FETCH depo_cur INTO depo_rec;

            IF depo_cur%NOTFOUND THEN
               IF TRIM (v_ust_depo) IS NULL THEN
                  durum := 'VAR';
                  RETURN;
               ELSE
                  --yetki tanimlanmamissa üst koda bak
                  -------------------------------------------------------
                  OPEN ust_cur (v_ust_depo);

                  FETCH ust_cur INTO ust_rec;

                  IF ust_cur%NOTFOUND THEN
                     durum := 'VAR';
                     RETURN;
                  ELSE
                     v_str_yetki := v_str_yetki || ust_rec.yetki_grubu;
                     durum       := yetki_pack.yetkisi_varmi (igiren_kullanici, v_str_yetki);

                     IF durum = '0' THEN
                        durum := 'YOK';
                     ELSE
                        durum := 'VAR';
                     END IF;

                     RETURN;
                  END IF;

                  CLOSE ust_cur;
               END IF;
            --depo kodu boslar içinde yetki tanimlanmissa yetki kotrolu yap
            ---------------------------------------------------------------
            ELSE
               v_str_yetki := v_str_yetki || depo_rec.yetki_grubu;
               durum       := yetki_pack.yetkisi_varmi (igiren_kullanici, v_str_yetki);

               IF durum = '0' THEN
                  durum := 'YOK';
               ELSE
                  durum := 'VAR';
               END IF;

               RETURN;
            END IF;

            CLOSE depo_cur;
         --depoya alani dolu ve böyle bir yetki kontrolu yapilmasi gerekiyorsa
         ---------------------------------------------------------------------
         ELSE
            v_str_yetki := v_str_yetki || xdepo_rec.yetki_grubu;
            durum       := yetki_pack.yetkisi_varmi (igiren_kullanici, v_str_yetki);

            IF durum = '0' THEN
               durum := 'YOK';
            ELSE
               durum := 'VAR';
            END IF;

            RETURN;
         END IF;

         CLOSE xdepo_cur;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         durum := 'KATEGORI_YETKI_VAR_MI :' || SQLERRM;
   END kategori_yetki_var_mi;

   PROCEDURE lokas_to_lokas_yapilabilir (iserial_number  IN     wiz_equip.serial_number%TYPE,
                                         iaccount_number IN     wiz_equip.account_number%TYPE,
                                         idepo_lokasyonu IN     wiz_equip_location_codes.equip_location_code%TYPE,
                                         its_kodu        IN     bt_bayi_teknik_servis.sales_agent_code%TYPE,
                                         ikullanici_kodu IN     co_kullanici.kod%TYPE,
                                         --[1  : wiz_equipta  , 2 :eq-ekipman da] --
                                         stbtip             OUT NUMBER,
                                         durum              OUT VARCHAR2
                                        ) IS
      v_serial_number              wiz_equip.serial_number%TYPE;
      v_yetki_no_assign_to_assign  NUMBER;
      v_yetki_bloke_depo           NUMBER;
      v_yetki_kayip_calinti        NUMBER;
      v_yetki_uyeye_verilemez      NUMBER;
      v_yetki_kayip_calintiya_atma NUMBER;
      v_aciklama                   wiz_equip_location_codes.descr%TYPE;
      v_assign                     wiz_equip_location_codes.assignable%TYPE;
      v_old_assign                 wiz_equip_location_codes.assignable%TYPE;
      v_calinti_lokasyon_flag      NUMBER;
      v_old_lokasyon               wiz_equip.equip_location_code%TYPE;
      v_equip_location_group_code  wiz_equip_location_codes.equip_location_group_code%TYPE;
   BEGIN
      durum                        := '0';
      v_calinti_lokasyon_flag      := 0;
      v_serial_number              := TRIM (iserial_number);
      v_equip_location_group_code  := NULL;

      IF LTRIM (v_serial_number) IS NULL THEN
         durum := '-1';
      END IF;

      BEGIN
         SELECT equip_location_code
           INTO v_old_lokasyon
           FROM wiz_equip
          WHERE serial_number = v_serial_number;

         stbtip := 1;
      --[Eq_ekipman i da lokasyondan lokasyona tasiyabilmek için]-----------------------------
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT equip_location_code
              INTO v_old_lokasyon
              FROM eq_ekipman
             WHERE serial_number = v_serial_number;

            stbtip := 2;
      END;

      v_yetki_no_assign_to_assign  := 1;
      v_yetki_uyeye_verilemez      := 1;
      v_yetki_kayip_calinti        := yetki_pack.yetkisi_varmi (ikullanici_kodu, 'ISLEM_EKIPMAN_KAYIP_CALINTI_LOKASYONUNDAN_ATAMA');
      v_yetki_kayip_calintiya_atma := yetki_pack.yetkisi_varmi (ikullanici_kodu, 'ISLEM_EKIPMAN_KAYIP_CALINTI_LOKASYONUNA_ATAMA');
      v_yetki_bloke_depo           := yetki_pack.yetkisi_varmi (ikullanici_kodu, 'ISLEM_EKIPMAN_BLOKE_DEPO');

      IF NOT LTRIM (v_old_lokasyon) IS NULL THEN
         valid_depo_lokasyon (v_old_lokasyon, v_aciklama, v_old_assign, v_equip_location_group_code, durum);

         IF durum <> '0' THEN
            durum := 'ESKİ DEPO KODU HATALI';
            RETURN;
         ELSIF v_yetki_bloke_depo = 0 AND RTRIM (LTRIM (v_equip_location_group_code)) = 'BLO' THEN
            durum := 'BLOKE DEPO ILE ISLEM YAPMA YETKINIZ YOK';
            RETURN;
         END IF;
      END IF;

      IF NOT LTRIM (idepo_lokasyonu) IS NULL THEN
         valid_depo_lokasyon (idepo_lokasyonu, v_aciklama, v_assign, v_equip_location_group_code, durum);

         IF durum <> '0' THEN
            durum := 'YENI DEPO KODU HATALI';
            RETURN;
         ELSIF v_old_assign = 'N' AND v_assign = 'Y' AND v_yetki_no_assign_to_assign = 0 THEN
            durum := 'ÜYEYE VERILEMEZ DEPODAN ÜYEYE VERILEBILIR DEPOYA ATAMA YETKINIZ YOK';
            RETURN;
         END IF;

         IF iaccount_number = 0 OR LTRIM (iaccount_number) IS NULL THEN
            SELECT COUNT (1)
              INTO v_calinti_lokasyon_flag
              FROM wiz_equip_location_codes,
                   bt_bayi_teknik_servis
             WHERE     bt_bayi_teknik_servis.sales_agent_code(+) = wiz_equip_location_codes.employee_code
                   AND wiz_equip_location_codes.equip_location_group_code = (SELECT deger
                                                                               FROM pa_sabitler
                                                                              WHERE adi = 'KAYIP_CALINTI_BLOKE_LOKASYON_GURUBU')
                   AND equip_location_code = v_old_lokasyon;

            IF v_calinti_lokasyon_flag > 0 AND v_yetki_kayip_calinti = 0 THEN
               durum := 'Kayip çalinti lokasyondan, üyeye verilebilir lokasyona atama yetkiniz yok!';
               RETURN;
            ELSIF v_assign = 'N' AND v_yetki_uyeye_verilemez = 0 THEN
               durum := 'Üyeye verilemez lokasyona atama için yetkiniz yok!';
               RETURN;
            END IF;
         ELSIF v_assign = 'N' THEN
            SELECT COUNT (1)
              INTO v_calinti_lokasyon_flag
              FROM wiz_equip_location_codes,
                   bt_bayi_teknik_servis
             WHERE     bt_bayi_teknik_servis.sales_agent_code(+) = wiz_equip_location_codes.employee_code
                   AND wiz_equip_location_codes.equip_location_group_code = (SELECT deger
                                                                               FROM pa_sabitler
                                                                              WHERE adi = 'KAYIP_CALINTI_BLOKE_LOKASYON_GURUBU')
                   AND equip_location_code = idepo_lokasyonu;

            IF v_calinti_lokasyon_flag > 0 AND v_yetki_kayip_calintiya_atma = 0 THEN
               durum := 'Kayip çalinti lokasyona atama için yetkiniz yok!';
               RETURN;
            ELSIF v_calinti_lokasyon_flag > 0 AND v_yetki_kayip_calintiya_atma <> 0 THEN
               durum := '0';
               RETURN;
            END IF;

            IF v_yetki_uyeye_verilemez = 0 THEN
               durum := 'Üyeye verilemez lokasyona atama için yetkiniz yok!';
               RETURN;
            END IF;
         END IF;

         IF TRIM (v_old_lokasyon) IS NOT NULL THEN
            kategori_yetki_var_mi (ikullanici_kodu, TRIM (v_old_lokasyon), TRIM (idepo_lokasyonu), 'DAL', durum);

            IF SUBSTR (durum, 1, 3) != 'VAR' THEN
               durum := 'BU EKIPMANI BU DEPODAN ALMA YETKINIZ YOK.';
               RETURN;
            ELSE
               durum := '0';
            END IF;
         END IF;

         IF TRIM (idepo_lokasyonu) IS NOT NULL THEN
            kategori_yetki_var_mi (ikullanici_kodu, TRIM (idepo_lokasyonu), TRIM (v_old_lokasyon), 'DAT', durum);

            IF SUBSTR (durum, 1, 3) != 'VAR' THEN
               durum := 'BU EKIPMANI BU DEPOYA ATMA YETKINIZ YOK.';
               RETURN;
            ELSE
               durum := '0';
            END IF;
         END IF;
      ELSE
         durum := 'DEPO KODU BOS';
         RETURN;
      END IF;
   END lokas_to_lokas_yapilabilir;

   PROCEDURE kontratsiz_aktif_yapilabilir (iaccount_number IN     wiz_equip.account_number%TYPE,
                                           iserial_number  IN     wiz_equip.serial_number%TYPE,
                                           ioutlet         IN     wiz_equip.outlet_location%TYPE,
                                           ikisi           IN     co_kullanici.kod%TYPE,
                                           durum              OUT VARCHAR2
                                          ) IS
      v_serial_number       wiz_equip.serial_number%TYPE;
      v_converter_type      wiz_equip.converter_type%TYPE;
      v_count               NUMBER (6);
      v_sonuc               NUMBER (3);
      v_ittp_order_int_open NUMBER;
      v_uyelik_durum        VARCHAR2 (50);
   BEGIN
      durum           := '0';
      v_serial_number := iserial_number;

      IF LTRIM (v_serial_number) IS NULL THEN
         durum := '-1';
      END IF;

      SELECT converter_type
        INTO v_converter_type
        FROM wiz_equip
       WHERE serial_number = v_serial_number;

      IF durum = '0' THEN
         uye_kontrol_pack.uye_icrada_mi (iaccount_number, durum);

         IF durum = '0' THEN
            -- Murat Aydin 10122013 ITTP ENTEGRASYON
            v_ittp_order_int_open := billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT');

            IF v_ittp_order_int_open = 0 THEN
               SELECT COUNT (*)
                 INTO v_count
                 FROM ie_uyelik_kapama
                WHERE account_number = iaccount_number AND durum = 'K';
            ELSIF v_ittp_order_int_open = 1 THEN
               v_count := 0;
               dbs_dba.uye_kontrol_pack.uye_sus_mu (iaccount_number, NULL, v_uyelik_durum);

               IF v_uyelik_durum <> '0' THEN
                  v_count := 1;
               END IF;
            END IF;

            IF v_count > 0 THEN
               durum := 'BU ABONENIN YAYINI BORCUNDAN DOLAYI KAPALI OLDUGUNDAN KONTRATSIZ AKTFILEME YAPAMAZSINIZ!';
               RETURN;
            END IF;

            uye_kontrol_pack.uye_illegal_mi (iaccount_number, ioutlet, ikisi, durum);

            IF durum <> '0' THEN
               durum := 'ÜYENIN BIR ÖNCEKI OUTLETI ILLEGAL VE BU ISLEM IÇIN YETKINIZ YOK.';
               RETURN;
            END IF;
         END IF;
      END IF;
   END kontratsiz_aktif_yapilabilir;

   /*--- Evren --- 20100916 --- begin ---*/
   PROCEDURE ekipman_degisimi_yapilabilirmi (i_old_eq_tip_matrix_id IN NUMBER, i_new_eq_tip_matrix_id IN NUMBER, o_durum OUT VARCHAR2) IS
      v_count               NUMBER;
      v_old_converter_model eq_ekipman_tip_matrix.converter_model%TYPE;
      v_new_converter_model eq_ekipman_tip_matrix.converter_model%TYPE;
   BEGIN
      o_durum := '0';

      SELECT TRIM (converter_model)
        INTO v_old_converter_model
        FROM eq_ekipman_tip_matrix
       WHERE eq_ekipman_tip_matrix_id = i_old_eq_tip_matrix_id;

      SELECT TRIM (converter_model)
        INTO v_new_converter_model
        FROM eq_ekipman_tip_matrix
       WHERE eq_ekipman_tip_matrix_id = i_new_eq_tip_matrix_id;

      SELECT COUNT (*)
        INTO v_count
        FROM eq_ekipman_degisim_matrixi x
       WHERE x.from_matrix_id = i_old_eq_tip_matrix_id AND x.to_matrix_id = i_new_eq_tip_matrix_id AND x.in_notin = 'IN';

      IF v_count = 0 THEN
         SELECT COUNT (*)
           INTO v_count
           FROM eq_ekipman_degisim_matrixi x
          WHERE x.from_matrix_id = i_old_eq_tip_matrix_id AND x.in_notin = 'IN';

         IF v_count > 0 THEN
            o_durum := TRIM (v_old_converter_model) || ' den ' || TRIM (v_new_converter_model) || ' ye ekipman değişimi yapılamaz.';
         ELSE
            SELECT COUNT (*)
              INTO v_count
              FROM eq_ekipman_degisim_matrixi x
             WHERE x.from_matrix_id = i_old_eq_tip_matrix_id AND x.to_matrix_id = i_new_eq_tip_matrix_id AND x.in_notin = 'NOTIN';

            IF v_count > 0 THEN
               o_durum := TRIM (v_old_converter_model) || ' den ' || TRIM (v_new_converter_model) || ' ye ekipman değişimi yapılamaz.';
            END IF;
         END IF;
      END IF;
   END;

   /*--- Evren --- 20100916 --- end ---*/
   PROCEDURE ekipman_ekle (iuye_no               IN     wiz_equip.account_number%TYPE,
                           iserial_number        IN     wiz_equip.serial_number%TYPE,
                           ioutlet_location      IN     wiz_equip.outlet_location%TYPE,
                           ibayi_kodu            IN     lg_ekipman.sales_agent_code%TYPE,
                           its_form_no           IN     tf_teknik_servis_formu.seri_no%TYPE,
                           ireason_code          IN     lg_ekipman.reason_code%TYPE,
                           idepoya               IN     lg_ekipman.depoya%TYPE,
                           iservice_address_id   IN     wiz_customer_hp_life.service_address_id%TYPE,
                           ikontratsiz_aktifleme IN     VARCHAR2,
                           iotel_mi              IN     VARCHAR2,
                           igiren_kullanici      IN     co_kullanici.kod%TYPE,
                           in_otorizasyon_no     IN     lg_ekipman.otorizasyon_no%TYPE,
                           in_ts_sifre_id        IN     lg_ekipman.lg_teknik_servis_sifre_id%TYPE,
                           in_sozlesme_no        IN     lg_ekipman.sozlesme_no%TYPE,
                           in_aciklama           IN     lg_ekipman.aciklama%TYPE,
                           odurum                   OUT VARCHAR2,
                           oproc_name               OUT VARCHAR2,
                           ois_emri                 OUT VARCHAR2,
                           oerror_type              OUT NUMBER,
                           oerror_code              OUT VARCHAR2,
                           oerror_text              OUT VARCHAR2,
                           in_ts_guncel_isl      IN     VARCHAR2 := 'H' --TS güncelleme islemleri yapilsin mi?
                          ) IS
      v_count                       NUMBER (3);
      v_sonuc                       VARCHAR2 (512);
      v_mesaj                       VARCHAR2 (512);
      v_customer_status             VARCHAR2 (2);
      v_islem_tipi                  NUMBER (2);
      v_type                        VARCHAR2 (2);
      v_converter_model             wiz_equip.converter_model%TYPE;
      v_old_lokasyon                wiz_equip.equip_location_code%TYPE;
      v_uye_no                      wiz_equip.account_number%TYPE;
      v_service_address_id          wiz_customer_hp_life.service_address_id%TYPE;
      v_outlet_location             wiz_equip.outlet_location%TYPE;
      v_channel_map_1               wiz_equip.channel_map_1%TYPE;
      v_channel_map_2               wiz_equip.channel_map_2%TYPE;
      v_channel_map_3               wiz_equip.channel_map_3%TYPE;
      v_channel_map_4               wiz_equip.channel_map_4%TYPE;
      v_ppv_purchase_current_limit  wiz_equip.ppv_purchase_current_limit%TYPE;
      v_work_order_number           NUMBER (10); --wiz_work_order.work_order_number%TYPE;
      v_trx_tarih                   wiz_equip_trx.trx_date%TYPE;
      v_ekipman_account_number      wiz_equip.account_number%TYPE;
      v_wiz_employee_code           co_kullanici.wiz_employee_code%TYPE;
      v_assignable                  wiz_equip_location_codes.assignable%TYPE;
      v_wiz_operator_id             co_kullanici.wiz_operator_id%TYPE;
      v_kart_durum                  eq_kart_durumu.durum%TYPE;
      v_abone_stb_tipi              wiz_customer_hp_life.hp_cluster%TYPE;
      v_manufacturer                wiz_equip.manufacturer%TYPE;
      p_statu                       mb_abone_statu.statu%TYPE;
      p_eski_statu                  mb_abone_statu.eski_statu%TYPE;
      p_detay_statu                 mb_abone_statu.detay_statu%TYPE;
      p_return_status               VARCHAR2 (1024);
      v_sozlesme_no                 yk_dp_kontrat.sozlesme_no%TYPE;
      v_tk_kart_no                  wiz_equip.serial_number%TYPE;
      vsc_no                        VARCHAR2 (20);
      vsc_durum                     CHAR (1);
      vst_no                        VARCHAR2 (20);
      vst_durum                     CHAR (1);
      vsozlesme_no                  VARCHAR2 (10);
      vsozlesme_durum               CHAR (1);
      vmodul_no                     VARCHAR2 (20);
      vmodul_durum                  CHAR (1);
      vmodul_tip                    NUMBER (10);
      v_chip_no                     VARCHAR2 (20);
      v_chip_durum                  VARCHAR (20);
      vstokkodu                     VARCHAR2 (20);
      veslenik_id                   NUMBER;
      v_paramyko                    VARCHAR2 (3);
      v_ekipmandeposbt              VARCHAR2 (1);
      v_ekipmandepoyetki            NUMBER;
      v_manufacturer_uyumlu         VARCHAR2 (1); -- E/H
      v_irdeto_destekli             VARCHAR2 (1); -- E/H
      v_serial_sahiplik             wiz_equip.serial_number%TYPE;
      v_ozellik_satilik             VARCHAR2 (1);
      v_brand_ozellik_satilik       VARCHAR2 (1);
      o_ekipman_sahibi_tipi         VARCHAR2 (1);
      vkutusahibikullanicidanfarkli BOOLEAN;
      v_sahip_uye                   VARCHAR2 (10);
      v_sahip_outlet                VARCHAR2 (3);
      v_ekipman_tipi                NUMBER (3);
      v_ekipman_tip_matrix_id       NUMBER;
      v_eski_ekipman_tip_matrix_id  NUMBER;
      v_depo_kontrolu               BOOLEAN;
      out_result                    VARCHAR2 (1);
      v_result_type                 VARCHAR2 (10);
      v_result_code                 VARCHAR2 (50);
      v_result_message              VARCHAR2 (256);
      v_ittp_order_int_open         NUMBER;
      v_servis_dusur                CHAR (1);
      v_servis_dusur_ok             VARCHAR2 (2000);
      v_kampanya_kodu               yk_dp_kontrat.campaign_code%TYPE;
      v_ekipman_musteri_tipi_uyum   BOOLEAN;
      v_franchise_code              wiz_customer_hp_life.franchise_code%TYPE;
      v_customer_type               wiz_customer_hp_life.customer_type%TYPE;
      indx                          NUMBER := 0;
      wo_durum                      VARCHAR2 (2000);
      v_work_order_count            NUMBER;
      v_servis_hatirlat             CHAR (3);
      v_log_return_status           VARCHAR2 (2000);
      v_hemen_kapat                 CHAR (1);
      v_auth_sonuc                  NUMBER;
      v_auth_sonuc_kod              VARCHAR2 (2000);
      v_auth_msg                    VARCHAR2 (2000);
      v_ittp_token                  VARCHAR2 (2000);
      v_ittp_dropoffer_sonuc        NUMBER;
      v_ittp_dropoffer_sonuc_kod    VARCHAR2 (2000);
      v_ittp_dropoffer_sonuc_msg    VARCHAR2 (2000);
      -- irdeto desteli mi parametreleri
      v_sc_ekipman_no               VARCHAR (512);
      v_st_ekipman_no               VARCHAR (512);

      v_md_ekipman_no               VARCHAR (512);
      v_manufactureruyumlu          VARCHAR (512);
      v_irdetodestekliekipman       VARCHAR (512);

      TYPE t_service IS RECORD
      (
         id                NUMBER,
         service_code      wiz_customer_hp_svc.service_code%TYPE,
         campaign_code     wiz_customer_hp_svc.campaign_code%TYPE,
         service_frequence wiz_customer_hp_svc.servis_frekansi%TYPE,
         closed_date       DATE
      );

      v_t_service                   t_service;

      TYPE tb_service IS TABLE OF t_service;

      v_t_services                  tb_service := tb_service ();
   BEGIN
      odurum                       := '0';
      oerror_type                  := 0;
      oerror_code                  := 'VLD348';
      oerror_text                  := NULL;
      v_uye_no                     := TRIM (iuye_no);
      v_outlet_location            := TRIM (ioutlet_location);
      v_service_address_id         := TRIM (iservice_address_id);

      IF LTRIM (iuye_no) IS NULL THEN
         odurum      := 'UYE NO BILGISI BOS';
         oproc_name  := 'EKIPMAN EKLE';
         oerror_type := 1;
         oerror_code := 'ERR351';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF LTRIM (iserial_number) IS NULL THEN
         odurum      := 'EKIPMAN NO BILGISI BOS';
         oproc_name  := 'EKIPMAN EKLE';
         oerror_type := 1;
         oerror_code := 'ERR351';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF LTRIM (ioutlet_location) IS NULL THEN
         odurum      := 'OUTLET BILGISI BOS' || iserial_number;
         oproc_name  := 'EKIPMAN EKLE';
         oerror_type := 1;
         oerror_code := 'ERR351';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF LTRIM (ibayi_kodu) IS NULL THEN
         odurum      := 'BAYI KODU BILGISI BOS';
         oproc_name  := 'EKIPMAN EKLE';
         oerror_type := 1;
         oerror_code := 'ERR365';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF LTRIM (ireason_code) IS NULL THEN
         odurum      := 'SEBEP KODU BILGISI BOS';
         oproc_name  := 'EKIPMAN EKLE';
         oerror_type := 1;
         oerror_code := 'ERR347';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF LTRIM (iservice_address_id) IS NULL THEN
         odurum      := 'ADRES ID BILGISI BOS';
         oproc_name  := 'EKIPMAN EKLE';
         oerror_type := 1;
         oerror_code := 'ERR347';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF LTRIM (igiren_kullanici) IS NULL THEN
         odurum      := 'KULLANICI BILGISI BOS';
         oproc_name  := 'EKIPMAN EKLE';
         oerror_type := 1;
         oerror_code := 'ERR347';
         oerror_text := odurum;
         RETURN;
      END IF;

      SELECT COUNT (*)
        INTO v_count
        FROM mb_abone_statu
       WHERE account_number = v_uye_no AND outlet_location = v_outlet_location AND statu = 'T' AND eski_statu IS NOT NULL;

      IF v_count > 0 THEN
         odurum      := 'Üyenin bu outleti adres transferi veya kutu tipi degisikligi yapilarak baska bir abonelige tasinmis old. ekipman eklenemez.';
         oproc_name  := 'EKIPMAN EKLE';
         oerror_type := 1;
         oerror_code := 'ERR347';
         oerror_text := odurum;
         RETURN;
      END IF;

      SELECT COUNT (*)
        INTO v_count
        FROM mb_abone_ozellik
       WHERE account_number = v_uye_no AND abone_ozellik_kodu = 155 AND (outlet_location = v_outlet_location OR outlet_location IS NULL);

      IF v_count > 0 THEN
         odurum      := 'Ekipman eklenemez !!! ' || dbs_sabit ('ADDRESSABLE_ISLEM_YAPAMAZ');
         oproc_name  := 'EKIPMAN EKLE';
         oerror_type := 1;
         oerror_code := 'ERR346';
         oerror_text := odurum;
         RETURN;
      END IF;

      /*
      Ekipman  eklemede özellik kodu kontrolu :
      Bu kontrol,  mutabakat sirasinda ts lerin elinde bulunan kartlari üyeye vermemeleri için yapildi..
      */
      IF dbs_sabit ('KULLANILABILIR_EKIPMAN_KONTROLU') = 'E' THEN
         SELECT COUNT (*)
           INTO v_count
           FROM eq_ekipman_ozellik
          WHERE serial_number = iserial_number AND ozellik_kodu = dbs_sabit ('KULLANILABILIR_EKIPMAN_OZELLIK');

         IF v_count > 0 THEN
            IF yetki_pack.yetkisi_varmi (igiren_kullanici, 'ISLEM_KULLANILABILIR_OLMAYAN_EKIPMAN_EKLE') = 0 THEN
               odurum      := 'EKLENEBILME OZELLIGI OLMADIGI IÇIN BU EKIPMAN EKLENEMEZ!';
               oproc_name  := 'EKIPMAN EKLE';
               oerror_type := 1;
               oerror_code := 'ERR462';
               oerror_text := 'EKLENEBILME OZELLIGI OLMADIGI IÇIN BU EKIPMAN EKLENEMEZ!';
               RETURN;
            END IF;
         END IF;
      END IF;

      -- Zafer KOYUNCU: Test ekipmanı için yeni blok eklendi - Kodu 247
      SELECT COUNT (*)
        INTO v_count
        FROM eq_ekipman_ozellik
       WHERE serial_number = iserial_number AND ozellik_kodu = 247;

      IF v_count > 0 THEN
         odurum      := 'TEST EKIPMANI ÖZELLIGI OLDUGU IÇIN BU EKIPMAN EKLENEMEZ!';
         oproc_name  := 'EKIPMAN EKLE';
         oerror_type := 1;
         oerror_code := 'ERR462';
         oerror_text := 'TEST EKIPMANI ÖZELLIGI OLDUGU IÇIN BU EKIPMAN EKLENEMEZ!';
         RETURN;
      END IF;

      -- Zafer KOYUNCU: SILINMIS_EKIPMAN_OZELLIK 'in ismi değiştiği için yerine kodu konuldu  - 107
      SELECT COUNT (*)
        INTO v_count
        FROM eq_ekipman_ozellik
       WHERE serial_number = iserial_number AND ozellik_kodu = 107;

      IF v_count > 0 THEN
         odurum      := 'SILINMIS ÖZELLIGI OLDUGU IÇIN BU EKIPMAN EKLENEMEZ!';
         oproc_name  := 'EKIPMAN EKLE';
         oerror_type := 1;
         oerror_code := 'ERR462';
         oerror_text := 'SILINMIS ÖZELLIGI OLDUGU IÇIN BU EKIPMAN EKLENEMEZ!';
         RETURN;
      END IF;

      --kart inactive ve deactive Ise
      IF TRIM (igiren_kullanici) <> 'SYSTEM' THEN
         BEGIN
            SELECT durum
              INTO v_kart_durum
              FROM (SELECT   durum
                        FROM eq_kart_durumu
                       WHERE serial_number = TRIM (iserial_number)
                    ORDER BY id DESC)
             WHERE ROWNUM = 1;

            --yetkisi yok ise
            ---------------------
            IF yetki_pack.yetkisi_varmi (TRIM (igiren_kullanici), 'ISLEM_KULLANILAMAZ_KARTI_UYEYE_VEREBILME') = 0 THEN
               IF TRIM (v_kart_durum) = 'I' THEN
                  odurum      :=    'YENI KART, KULLANILAMAZ KARTLAR ARASINDA.'
                                 || CHR (10)
                                 || 'BU KARTIN ACILEN DIGITURK''E GÖNDERILMESI GEREKMEKTEDIR!'
                                 || CHR (10)
                                 || 'ÜYEYE VERILEMEZ.';
                  oproc_name  := 'EKIPMAN EKLE';
                  oerror_type := 1;
                  oerror_code := 'ERR357';
                  oerror_text := odurum;
                  RETURN;
               ELSIF TRIM (v_kart_durum) = 'D' THEN
                  IF kill_ekipman_donus_pack.kart_ad0_da_mi (TRIM (iserial_number), SYSDATE) = FALSE THEN
                     odurum      :=    'YENI KART AKTIF DURUMDA DEGIL.'
                                    || CHR (10)
                                    || 'BU KARTIN ACILEN DIGITURK''E GÖNDERILMESI GEREKMEKTEDIR!'
                                    || CHR (10)
                                    || 'ÜYEYE VERILEMEZ.';
                     oproc_name  := 'EKIPMAN EKLE';
                     oerror_type := 1;
                     oerror_code := 'ERR358';
                     oerror_text := odurum;
                     RETURN;
                  END IF;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END IF;

      BEGIN
         SELECT a.account_number, a.equip_location_code, TRIM (a.converter_type), TRIM (a.converter_model), b.assignable, a.manufacturer
           INTO v_ekipman_account_number, v_old_lokasyon, v_type, v_converter_model, v_assignable, v_manufacturer
           FROM wiz_equip a,
                wiz_equip_location_codes b
          WHERE a.equip_location_code = b.equip_location_code(+) AND a.serial_number = iserial_number;

         IF v_ekipman_account_number <> '0' THEN
            odurum      :=    'EKIPMAN ZATEN BIR ÜYE ÜZERINDE ISLEM YAPILAMAZ'
                           || iserial_number
                           || ' - account_number'
                           || v_ekipman_account_number
                           || ' IaC:'
                           || iuye_no;
            oproc_name  := 'EKIPMAN EKLE';
            oerror_type := 1;
            oerror_code := 'ERR359';
            oerror_text := odurum;
            RETURN;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            odurum      := 'EKIPMAN SISTEMDE YOK' || ' serial_number:' || iserial_number;
            oproc_name  := 'EKIPMAN EKLE';
            oerror_type := 1;
            oerror_code := 'ERR360';
            oerror_text := odurum;
            RETURN;
      END;

      v_paramyko                   := dbs_sabit ('YENI_KONTRAT');

      IF TRIM (v_old_lokasyon) IS NOT NULL THEN
         kategori_yetki_var_mi (igiren_kullanici, v_old_lokasyon, NULL, 'UAT', odurum);

         IF SUBSTR (odurum, 1, 3) != 'VAR' THEN
            odurum      := 'BU EKIPMANI BU DEPODAN UYEYE VERME YETKINIZ YOK.';
            oproc_name  := 'EKIPMAN_EKLE_CIKAR';
            oerror_type := 1;
            oerror_code := 'ERR356';
            oerror_text := odurum;
            RETURN;
         END IF;
      END IF;

      v_abone_stb_tipi             := vestel_pack.abone_stb_tipi_bul (iuye_no);

      IF yetki_pack.yetkisi_varmi (igiren_kullanici, 'EKIPMAN_UYUSMAYAN_EKIPMAN_EKLEME') = 0 THEN
         IF sozlesme_ekipman_uyumlu (v_abone_stb_tipi, iserial_number) = 0 THEN
            odurum      := 'BU ÜYE TIPI ILE EKIPMAN TIPI UYUSMAMAKTADIR.';
            oproc_name  := 'EKIPMAN_EKLE_CIKAR';
            oerror_type := 1;
            oerror_code := 'ERR362';
            oerror_text := odurum;
            RETURN;
         END IF;
      END IF;

      BEGIN
         v_depo_kontrolu         := TRUE;
         v_ozellik_satilik       := 'H';
         v_brand_ozellik_satilik := 'H';

         -- Eklenen kutunun tip id'si.
         SELECT eq_ekipman_tip_matrix_id
           INTO v_ekipman_tip_matrix_id
           FROM eq_ekipman_tip_matrix
          WHERE TRIM (converter_type) = TRIM (v_type) AND TRIM (converter_model) = TRIM (v_converter_model) AND TRIM (manufacturer) = TRIM (v_manufacturer);

         IF v_type = 'ST' THEN
            /*falamur 14042014  chip no ile ilgili illlegalite kontrolü*/

            DECLARE
               v_tmp_sc_serial_number VARCHAR2 (20);
               v_tmp_sc_durum         VARCHAR2 (1);
               v_tmp_st_no            VARCHAR2 (20);
               v_tmp_st_durum         VARCHAR2 (1);
               v_tmp_sozlesme_no      VARCHAR2 (20);
               v_tmp_sozlesme_durum   VARCHAR2 (1);
               v_tmp_modul_no         VARCHAR2 (20);
               v_tmp_modul_durum      VARCHAR2 (1);
               v_tmp_modul_tip        VARCHAR2 (20);
               v_tmp_ch_serial_number VARCHAR2 (20);
               v_tmp_chip_durum       VARCHAR2 (1);
               v_tmp_stokkodu         VARCHAR2 (20);
               v_tmp_eslenik_id       NUMBER;
            BEGIN
               stok_dba.dp_stok_eslenik.eslenik_bul (iserial_number,
                                                     'ST',
                                                     v_tmp_sc_serial_number,
                                                     v_tmp_sc_durum,
                                                     v_tmp_st_no,
                                                     v_tmp_st_durum,
                                                     v_tmp_sozlesme_no,
                                                     v_tmp_sozlesme_durum,
                                                     v_tmp_modul_no,
                                                     v_tmp_modul_durum,
                                                     v_tmp_modul_tip,
                                                     v_tmp_ch_serial_number,
                                                     v_tmp_chip_durum,
                                                     v_tmp_stokkodu,
                                                     v_tmp_eslenik_id
                                                    );

               IF TRIM (v_tmp_ch_serial_number) IS NOT NULL THEN
                  SELECT COUNT (1)
                    INTO v_count
                    FROM eq_ekipman_ozellik
                   WHERE serial_number = v_tmp_ch_serial_number AND ozellik_kodu = 432;

                  IF v_count > 0 THEN
                     odurum      := 'Bu kutu üyeye eklenemez. Chip numarası kullanılamaz kutu! ';
                     oerror_type := 1;
                     oerror_code := 'ERR346';
                     oerror_text := odurum;
                     RETURN;
                  END IF;
               END IF;
            END;

            /*end falamur*/

            /*bozturkmen - ekipmanın diğer özelliklerini kontrol etmeden önce müşteri tip ile uyumu kontrol edilir.*/
            -- Ozgur Arslan  Kutu eklenirken HDD check et
            -- Eger kutu HDD destekli degilse ve uye üzerinde hdd varsa uyarı vermemiz gerekli yoksa kutu eklenebilir
            -- sadece HDD eklenebilir uyeye kutu olması şartı yok
            IF (eq_ekipman_hdd_var_mi (v_uye_no, v_outlet_location) = 1 AND eq_hdd_zorunlu_ozellik_kutu (iserial_number) = 0) THEN
               odurum      :=    'EKLENEN KUTUNUN HARDDISK OZELLIGI YOK.'
                              || CHR (10)
                              || 'BU KUTUNUN HDD DESTEKLI OLMASI GEREKMEKTEDIR!'
                              || CHR (10)
                              || 'ÜYEDE HARDDISK EKIPMAN MEVCUTTUR.';
               oproc_name  := 'EKIPMAN EKLE';
               oerror_type := 1;
               oerror_code := 'ERR462';
               oerror_text := odurum;
               RETURN;
            END IF;

            v_ekipman_tipi    := 247;
            v_ozellik_satilik := ekipman_satilikmi (iserial_number, NULL, NULL, v_old_lokasyon);

            -- IBX0000950 IRDETO
            -- Ekipman satilik ise ödeme ve sahiplik yaratilmali sonra ekipman ekleme yapilmali.
            -- Kutu modelinden bagimsiz, brand üzerinde satilik özelligi varsa da sahiplik yaratiliyor 2007

            ------------------------------------------
            -- Evrim Kayan Ağustos 2009,
            -- Üyenin üzerindeki veya iş emirlerindeki servis, sadece TURKSAT servisi ise, kutusu TURKSAT destekli olmalı.
            --            SELECT SUM (ozellik_kodu)
            --              INTO v_count
            --              FROM (SELECT hps.service_code service_code
            --                      FROM wiz_customer_hp_svc hps
            --                     WHERE account_number = v_uye_no AND outlet_location = v_outlet_location
            --                    UNION
            --                    SELECT wol.service_code service_code
            --                      FROM wiz_work_order wo, wiz_wo_line_items wol
            --                     WHERE wo.work_order_number = wol.work_order_number
            --                       AND wo.wo_status IN ('O', 'P')
            --                       AND wol.wo_status = 'O'
            --                       AND wol.job_code = 'ADD'
            --                       AND wo.account_number = v_uye_no
            --                       AND wol.outlet_location = v_outlet_location) t,
            --                   pr_urun_ozellik_tanim pr
            --             WHERE pr.urun_kodu = t.service_code AND urun_tipi = '2' AND ozellik_kodu IN (13, 14)
            --                   AND listeden_gizle = 'H';

            ---- Yukarda ki sorgu yerine artık üye uydusu sorgusu kullanılabilir. Üye türksat paketiri var ise ozellik kontrol ediliyor.
            IF abone_sorgu_pack.uye_uydusu (v_uye_no, v_outlet_location) = 2 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM pr_urun_ozellik_tanim pr
                WHERE ekipman_tip_matrix_id = v_ekipman_tip_matrix_id AND urun_tipi = '6' AND ozellik_kodu IN (70, 69) AND listeden_gizle = 'H';

               IF v_count = 0 THEN
                  odurum      := 'Üye TURSAT servisi izlemektedir. Kutu TURKSAT destekli değildir. !';
                  oproc_name  := 'EKIPMAN_EKLE_CIKAR';
                  oerror_type := 1;
                  oerror_code := 'ERR356';
                  oerror_text := odurum;
                  RETURN;
               END IF;
            END IF;

            BEGIN
               SELECT   ozellik_degeri
                   INTO v_brand_ozellik_satilik
                   FROM pr_genel_tip_detay d,
                        pr_stb_tipi_ozellik o
                  WHERE o.ozellik_kodu = d.tip_kodu AND d.islem_kodu = 150 AND o.kod = v_abone_stb_tipi AND ozellik_kodu = 4
               ORDER BY o.ozellik_kodu;
            EXCEPTION
               WHEN OTHERS THEN
                  v_brand_ozellik_satilik := 'H';
            END;
         END IF;

         v_sahip_uye             := ekipman_sahibi_kim (iserial_number, o_ekipman_sahibi_tipi, v_sahip_outlet);
         v_serial_sahiplik       := ekipman_sahibi (v_uye_no, v_outlet_location, v_ekipman_tipi);

         -- v_depo_kontrolu takibi:
         -- Kutu satilik ise
         --     Kutuya sahipse, kutu zaten abonededir, depodan çikisi kontrolü söz konusu degildir
         --     Kontrattan geliyorsa, depo kontrolü yapilmaz.
         IF ( (v_ozellik_satilik = 'E' OR v_brand_ozellik_satilik = 'E') AND (v_serial_sahiplik = iserial_number OR ireason_code = v_paramyko)) THEN
            v_depo_kontrolu := FALSE;
         END IF;

         IF v_depo_kontrolu THEN
            v_ekipmandeposbt   := 'H';
            v_ekipmandepoyetki := 1;

            IF v_abone_stb_tipi = 'PH' THEN
               v_ekipmandeposbt   := dbs_sabit ('BAYI_TS_KENDI_DEPOSUNDAN_EKIPMAN_EKLEMELI');
               v_ekipmandepoyetki := yetki_pack.yetkisi_varmi (igiren_kullanici, 'DEPO_EKIPMAN_UYUMU_KONTROLU_ATLA');
            -- STB_TIPI  PH'dan farkli olan üyeler için aktivasyon yapilirken, bir servisin sahip oldugu depolardaki
            -- ekipmanlar ekleme islemi yapilabilir.
            -- Bu islem için bir sabit ve birde yetki tanimlanmistir.
            ELSE
               v_ekipmandeposbt   := dbs_sabit ('BAYI_TS_KENDI_DEPOSUNDAN_EKIPMAN_EKLEMELI_DIGER');
               v_ekipmandepoyetki := yetki_pack.yetkisi_varmi (igiren_kullanici, 'DEPO_EKIPMAN_UYUMU_KONTROLU_DIGER_ATLA');
            END IF;

            IF v_ekipmandeposbt = 'E' AND v_ekipmandepoyetki = 0 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_equip we,
                      wiz_equip_location_codes wel
                WHERE     we.equip_location_code = wel.equip_location_code
                      AND (wel.ust_depo_kod = 'ZINCIR MAGAZA' OR (wel.employee_code = ibayi_kodu OR wel.employee_code IS NULL))
                      AND we.serial_number = iserial_number;

               IF v_count = 0 THEN
                  odurum      := 'BU EKIPMANI BU DEPODAN BU BAYI/TS ÜZERINDEN UYEYE VERME YETKINIZ YOK.';
                  oproc_name  := 'EKIPMAN_EKLE_CIKAR';
                  oerror_type := 1;
                  oerror_code := 'ERR356';
                  oerror_text := odurum;
                  RETURN;
               END IF;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            odurum      := 'EKIPMAN DEPO KONTROLÜ SIRASINDA HATA! ';
            oproc_name  := 'EKIPMAN_EKLE_CIKAR';
            oerror_type := 1;
            oerror_code := 'ERR356';
            oerror_text := odurum;
            RETURN;
      END;

      -- STB_TIPI = PH olan üyeler için aktivasyon yapilirken, bir servisin sahip oldugu depolardaki
      -- ekipmanlar ekleme islemi yapilabilir.
      -- Bu islem için bir sabit ve birde yetki tanimlanmistir.
      IF v_type = 'ST' THEN
         --OGM: yeni sahiplik yapisi
         IF v_sahip_uye IS NOT NULL AND o_ekipman_sahibi_tipi = 1 THEN
            --yeni ekipman sahipligi bir uyede ise
            vkutusahibikullanicidanfarkli := FALSE;

            IF yetki_pack.yetkisi_varmi (igiren_kullanici, 'EKIPMAN_SAHIBI_KULLANICISINDAN_FARKLI') <> 0 --uye ve outlet transferi yapabilir
                                                                                                        THEN
               IF (v_sahip_uye <> v_uye_no OR v_sahip_outlet <> v_outlet_location) THEN
                  vkutusahibikullanicidanfarkli := TRUE;
               -- Sahiplik transfer edilecek.
               END IF;
            ELSIF yetki_pack.yetkisi_varmi (igiren_kullanici, 'EKIPMAN_SAHIPLIK_OUTLET_DEGISIKLIGI') <> 0 --outlet transferi yapabilir
                                                                                                         THEN
               IF (v_sahip_uye = v_uye_no AND v_sahip_outlet <> v_outlet_location) THEN
                  vkutusahibikullanicidanfarkli := TRUE;
               -- Sahiplik transfer edilecek.
               END IF;
            END IF;

            IF (v_sahip_uye <> v_uye_no OR v_sahip_outlet <> v_outlet_location) THEN
               IF NOT vkutusahibikullanicidanfarkli THEN
                  odurum      := 'Ekipman sahipligi baska bir üye veya outlette görülüyor, bu kutu eklenemez!';
                  oproc_name  := 'EKIPMAN EKLE';
                  oerror_type := 1;
                  oerror_code := 'ERR362'; -- ??
                  oerror_text := odurum;
                  RETURN;
               END IF;
            END IF;

            IF vkutusahibikullanicidanfarkli THEN
               DECLARE
                  v_sebep_kodu     VARCHAR2 (3);
                  v_sebep_aciklama VARCHAR2 (100);
               BEGIN
                  IF v_sahip_uye <> v_uye_no THEN
                     v_sebep_aciklama := 'FARKLI ABONEYE YETKI ILE TRANSFER EDILDI';
                     v_sebep_kodu     := 'FAY';
                  ELSIF v_sahip_outlet <> v_outlet_location THEN
                     v_sebep_aciklama := 'EKIPMAN SAHIPLIGI OUTLET DEGISIKLIGI';
                     v_sebep_kodu     := 'ESO';
                  END IF;

                  eq_ekipman_sahibi_kim_transfer (iserial_number,
                                                  iserial_number,
                                                  v_uye_no,
                                                  v_outlet_location,
                                                  v_sebep_kodu,
                                                  v_sebep_kodu,
                                                  v_sebep_aciklama,
                                                  igiren_kullanici,
                                                  odurum
                                                 );

                  IF odurum <> '0' THEN
                     oproc_name  := 'EKIPMAN EKLE';
                     oerror_type := 1;
                     oerror_code := 'ERR362';
                     oerror_text := odurum;
                     RETURN;
                  END IF;
               END;
            END IF;
         ELSE --yeni ekipman sahipligi herhangi bir üyede degil
            IF v_serial_sahiplik IS NULL THEN --a)ESKI EKIPMAN ÜYEDE DEGILSE
               IF (v_ozellik_satilik = 'E' OR v_brand_ozellik_satilik = 'E') AND ireason_code <> v_paramyko THEN
                  odurum      := 'Üye bu outlet için ekipman satin almali. Öncelikle "Sahiplik" ekranindan satin alma islemi yapmalisiniz.';
                  oproc_name  := 'EKIPMAN EKLE';
                  oerror_type := 1;
                  oerror_code := 'ERR362';
                  oerror_text := odurum;
                  RETURN;
               END IF;
            ELSE
               --b)ESKI EKIPMAN ÜYEDE ISE (AYNI TIPLI EKIPMAN ISE TRANSDER EDILIR
               --AYNI MI
               ekipman_transfer_edilebilir_mi (v_serial_sahiplik,
                                               v_ekipman_tip_matrix_id,
                                               1,
                                               out_result,
                                               odurum,
                                               oproc_name,
                                               oerror_type,
                                               oerror_code,
                                               oerror_text
                                              );

               IF odurum <> '0' THEN
                  RETURN;
               END IF;

               --bu if aslinda yeni ekipman = eski ekipman mi kontrolu yapar
               --1=matrix ayni transfer edilebilir,
               --2=52 ozelligi var, isleme devam et ama transfer etme,
               --3=pr_urun_ozellik_tanim da kayit var transfer edilebilir
               --4=ekipman ayni degil, isleme devam etme (ELSE e düs)
               IF out_result IN ('1', '3') THEN
                  ekipman_pack.eq_ekipman_sahibi_kim_transfer (v_serial_sahiplik,
                                                               iserial_number,
                                                               v_uye_no,
                                                               v_outlet_location,
                                                               'EKD',
                                                               'EKD',
                                                               'EKIPMAN DEĞİŞİKLİĞİ',
                                                               igiren_kullanici,
                                                               odurum
                                                              );

                  IF odurum <> '0' THEN
                     RETURN;
                  END IF;
               ELSIF (v_ozellik_satilik = 'E' OR v_brand_ozellik_satilik = 'E') AND ireason_code <> v_paramyko THEN
                  odurum      := 'Üye bu outlet için ekipman satin almali. Öncelikle "Sahiplik" ekranindan satin alma islemi yapmalisiniz.';
                  oproc_name  := 'EKIPMAN EKLE';
                  oerror_type := 1;
                  oerror_code := 'ERR362'; -- ??
                  oerror_text := odurum;
                  RETURN;
               END IF;
            /*
                           IF out_result <> '4'
                           THEN
                              IF out_result <> '2'
                              THEN
                                 --52 ozelligi vardir. islem devam eder ama transfer etmez
                                 eq_ekipman_sahibi_kim_transfer (v_serial_sahiplik,
                                                                 iserial_number,
                                                                 v_uye_no,
                                                                 v_outlet_location,
                                                                 'EKD',
                                                                 'EKD',
                                                                 'EKIPMAN DEGISIKLIGI',
                                                                 igiren_kullanici,
                                                                 odurum
                                                                );

                                 IF odurum <> '0'
                                 THEN
                                    oproc_name := 'EKIPMAN EKLE';
                                    oerror_type := 1;
                                    oerror_code := 'ERR362';
                                    oerror_text := odurum;
                                    RETURN;
                                 END IF;
                              ELSE
                                 IF (v_ozellik_satilik = 'E' OR v_brand_ozellik_satilik = 'E') AND ireason_code <> v_paramyko
                                 THEN
                                    odurum := 'Üye bu outlet için ekipman satin almali. Öncelikle "Sahiplik" ekranindan satin alma islemi yapmalisiniz.';
                                    oproc_name := 'EKIPMAN EKLE';
                                    oerror_type := 1;
                                    oerror_code := 'ERR362';                                                                                                          -- ??
                                    oerror_text := odurum;
                                    RETURN;
                                 END IF;
                              END IF;
                           ELSE
                              IF (v_ozellik_satilik = 'E' OR v_brand_ozellik_satilik = 'E') AND ireason_code <> v_paramyko
                              THEN
                                 odurum := 'Üye bu outlet için ekipman satin almali. Öncelikle "Sahiplik" ekranindan satin alma islemi yapmalisiniz.';
                                 oproc_name := 'EKIPMAN EKLE';
                                 oerror_type := 1;
                                 oerror_code := 'ERR362';                                                                                                             -- ??
                                 oerror_text := odurum;
                                 RETURN;
                              END IF;
                           END IF;
                           */

            --/AYNI MI
            END IF;
         END IF;
      --/if v_type = 'ST';
      END IF;

      IF v_type = 'SC' THEN
         IF yetki_pack.yetkisi_varmi (igiren_kullanici, 'EKIPMAN_ESKI_VERSIYON_EKLEME') = 0 THEN
            IF ekipman_riskli_mi (iserial_number) = 1 THEN
               odurum      := 'EKIPMANIN VERSIYONU UYGUN DEGIL. EKLEYEMEZSINIZ.';
               oproc_name  := 'EKIPMAN EKLE';
               oerror_type := 1;
               oerror_code := 'ERR363';
               oerror_text := odurum;
               RETURN;
            END IF;
         END IF;
      END IF;

      /*--- Evren --- 20100916 --- begin ---*/
      SELECT COUNT (1)
        INTO v_count
        FROM co_memo_bilgi
       WHERE     abone_kodu = v_uye_no
             AND durum_kodu = 3
             AND acilis_tarihi > SYSDATE - 1
             AND EXISTS
                    (SELECT 1
                       FROM TABLE (split_table_fnc (dbs_sabit ('EKIPMAN_DEGISIM_MATRIX_KISIT_GEC_MEMO_KODU')))
                      WHERE COLUMN_VALUE = memo_kodu);

      IF yetki_pack.yetkisi_varmi (igiren_kullanici, 'ISLEM_EKIPMAN_DEGISIM_MATRIX_KISITI') = 0 AND v_count = 0 THEN
         BEGIN
            SELECT d.eq_ekipman_tip_matrix_id
              INTO v_eski_ekipman_tip_matrix_id
              FROM (SELECT *
                      FROM (SELECT   b.*
                                FROM lg_ekipman a,
                                     wiz_equip b
                               WHERE     a.account_number = v_uye_no
                                     AND a.outlet_location = v_outlet_location
                                     AND a.depoya IS NOT NULL
                                     AND a.depodan IS NULL
                                     AND a.serial_number = b.serial_number
                                     AND b.converter_type = v_type
                            ORDER BY a.islem_tarihi DESC,
                                     a.id DESC)
                     WHERE ROWNUM = 1) c,
                   eq_ekipman_tip_matrix d
             WHERE     TRIM (c.manufacturer) = TRIM (d.manufacturer)
                   AND TRIM (c.converter_type) = TRIM (d.converter_type)
                   AND TRIM (c.converter_model) = TRIM (d.converter_model);

            IF v_type = 'SC' THEN
               -- Eğer SC V6.0 dan V5.7  veya 5.4 karta geçiş yapılıyorsa ve HDD destekli kutu ise kayıtlı içerikler izlenemiyor.
               DECLARE
                  v_st_serial_number          VARCHAR2 (20);
                  o_tmp_ekipman_tip_matrix_id eq_ekipman_tip_matrix.eq_ekipman_tip_matrix_id%TYPE;
                  o_hdd_destekli              CHAR (1);
               BEGIN
                  SELECT serial_number
                    INTO v_st_serial_number
                    FROM wiz_equip
                   WHERE account_number = v_uye_no AND outlet_location = v_outlet_location AND converter_type = 'ST';

                  ekipman_ozellik (v_st_serial_number, NULL, NULL, 28, o_tmp_ekipman_tip_matrix_id, o_hdd_destekli);

                  IF o_hdd_destekli = 'E' THEN
                     ekipman_degisimi_yapilabilirmi (v_eski_ekipman_tip_matrix_id, v_ekipman_tip_matrix_id, odurum);

                     IF odurum <> '0' THEN
                        RETURN;
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;
               END;
            ELSE
               ekipman_degisimi_yapilabilirmi (v_eski_ekipman_tip_matrix_id, v_ekipman_tip_matrix_id, odurum);

               IF odurum <> '0' THEN
                  RETURN;
               END IF;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;

         --MKECECI - v7.0 PRE kart ile DT-PHI7100 kutunun verilmemesi sağlandı-10.07.2014
         BEGIN
            IF v_type = 'SC' THEN
               SELECT eq.eq_ekipman_tip_matrix_id
                 INTO v_ekipman_tip_matrix_id
                 FROM wiz_equip wz,
                      eq_ekipman_tip_matrix eq
                WHERE     TRIM (wz.converter_model) = TRIM (eq.converter_model)
                      AND TRIM (wz.converter_type) = TRIM (eq.converter_type)
                      AND TRIM (wz.manufacturer) = TRIM (eq.manufacturer)
                      AND wz.converter_type = v_type
                      AND wz.serial_number = iserial_number;

               SELECT eq.eq_ekipman_tip_matrix_id
                 INTO v_eski_ekipman_tip_matrix_id
                 FROM wiz_equip wz,
                      eq_ekipman_tip_matrix eq
                WHERE     TRIM (wz.converter_model) = TRIM (eq.converter_model)
                      AND TRIM (wz.converter_type) = TRIM (eq.converter_type)
                      AND TRIM (wz.manufacturer) = TRIM (eq.manufacturer)
                      AND wz.converter_type = 'ST'
                      AND wz.account_number = v_uye_no
                      AND wz.outlet_location = v_outlet_location;

               ekipman_degisimi_yapilabilirmi (v_ekipman_tip_matrix_id, v_eski_ekipman_tip_matrix_id, odurum);

               IF odurum <> '0' THEN
                  RETURN;
               END IF;
            ELSIF v_type = 'ST' THEN
               SELECT eq.eq_ekipman_tip_matrix_id
                 INTO v_eski_ekipman_tip_matrix_id
                 FROM wiz_equip wz,
                      eq_ekipman_tip_matrix eq
                WHERE     TRIM (wz.converter_model) = TRIM (eq.converter_model)
                      AND TRIM (wz.converter_type) = TRIM (eq.converter_type)
                      AND TRIM (wz.manufacturer) = TRIM (eq.manufacturer)
                      AND wz.converter_type = v_type
                      AND wz.serial_number = iserial_number;

               SELECT eq.eq_ekipman_tip_matrix_id
                 INTO v_ekipman_tip_matrix_id
                 FROM wiz_equip wz,
                      eq_ekipman_tip_matrix eq
                WHERE     TRIM (wz.converter_model) = TRIM (eq.converter_model)
                      AND TRIM (wz.converter_type) = TRIM (eq.converter_type)
                      AND TRIM (wz.manufacturer) = TRIM (eq.manufacturer)
                      AND wz.converter_type = 'SC'
                      AND wz.account_number = v_uye_no
                      AND wz.outlet_location = v_outlet_location;

               ekipman_degisimi_yapilabilirmi (v_ekipman_tip_matrix_id, v_eski_ekipman_tip_matrix_id, odurum);

               IF odurum <> '0' THEN
                  RETURN;
               END IF;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      --</end>
      END IF;

      /*--- Evren --- 20100916 --- end ---*/
      DECLARE
         out_irdeto_destekli VARCHAR2 (1);
         out_durum           VARCHAR2 (250);
      BEGIN
         --ekipman_irdeto_desteklimi (iserial_number, out_irdeto_destekli, out_durum);

         ekipman_pack.ekipman_irdeto_desteklimi (iuye_no,
                                                 ioutlet_location,
                                                 iserial_number,
                                                 v_manufacturer,
                                                 v_type,
                                                 v_converter_model,
                                                 'E',
                                                 v_sc_ekipman_no,
                                                 v_st_ekipman_no,
                                                 v_md_ekipman_no,
                                                 v_manufactureruyumlu,
                                                 v_irdetodestekliekipman,
                                                 v_sonuc
                                                );

         IF v_sonuc <> '0' THEN
            odurum := v_sonuc;
            RETURN;
         END IF;

         -- PVR kutularda da eslenik var, buraya girmesin.
         IF v_irdetodestekliekipman = 'H' THEN -- out_irdeto_destekli = 'H' THEN
            stok_dba.dp_stok_eslenik.eslenik_bul (iserial_number,
                                                  v_type,
                                                  vsc_no,
                                                  vsc_durum,
                                                  vst_no,
                                                  vst_durum,
                                                  vsozlesme_no,
                                                  vsozlesme_durum,
                                                  vmodul_no,
                                                  vmodul_durum,
                                                  vmodul_tip,
                                                  v_chip_no,
                                                  v_chip_durum,
                                                  vstokkodu,
                                                  veslenik_id,
                                                  'F'
                                                 );

            IF veslenik_id <> 0 THEN
               odurum := '0';

               IF v_type = 'SC' AND vsc_no = iserial_number AND vsc_durum = 'E' THEN
                  stok_dba.dp_stok_eslenik.eslenik_guncelle (veslenik_id, iserial_number, 'SC', 'H', igiren_kullanici, 'H', odurum);

                  IF odurum = '0' AND vst_durum = 'E' AND ireason_code <> v_paramyko THEN
                     ekipman_ekle (iuye_no,
                                   vst_no,
                                   ioutlet_location,
                                   ibayi_kodu,
                                   its_form_no,
                                   ireason_code,
                                   idepoya,
                                   iservice_address_id,
                                   ikontratsiz_aktifleme,
                                   iotel_mi,
                                   igiren_kullanici,
                                   in_otorizasyon_no,
                                   in_ts_sifre_id,
                                   in_sozlesme_no,
                                   in_aciklama,
                                   odurum,
                                   oproc_name,
                                   ois_emri,
                                   oerror_type,
                                   oerror_code,
                                   oerror_text,
                                   in_ts_guncel_isl --TS güncelleme islemleri yapilsin mi?
                                  );

                     IF odurum <> '0' THEN
                        RETURN;
                     END IF;
                  END IF;
               ELSIF v_type = 'ST' AND vst_no = iserial_number AND vst_durum = 'E' THEN
                  stok_dba.dp_stok_eslenik.eslenik_guncelle (veslenik_id, iserial_number, 'ST', 'H', igiren_kullanici, 'H', odurum);

                  IF odurum = '0' AND vsc_durum = 'E' AND ireason_code <> v_paramyko THEN
                     ekipman_ekle (iuye_no,
                                   vsc_no,
                                   ioutlet_location,
                                   ibayi_kodu,
                                   its_form_no,
                                   ireason_code,
                                   idepoya,
                                   iservice_address_id,
                                   ikontratsiz_aktifleme,
                                   iotel_mi,
                                   igiren_kullanici,
                                   in_otorizasyon_no,
                                   in_ts_sifre_id,
                                   in_sozlesme_no,
                                   in_aciklama,
                                   odurum,
                                   oproc_name,
                                   ois_emri,
                                   oerror_type,
                                   oerror_code,
                                   oerror_text,
                                   in_ts_guncel_isl --TS güncelleme islemleri yapilsin mi?
                                  );

                     IF odurum <> '0' THEN
                        RETURN;
                     END IF;
                  END IF;
               ELSIF v_type = 'MD' AND vmodul_no = iserial_number AND vmodul_durum = 'E' THEN
                  stok_dba.dp_stok_eslenik.eslenik_guncelle (veslenik_id, iserial_number, 'MD', 'H', igiren_kullanici, 'H', odurum);
               END IF;

               IF odurum <> 0 THEN
                  oproc_name  := 'EKIPMAN_EKLE_CIKAR';
                  oerror_type := 1;
                  oerror_code := 'ERR346';
                  oerror_text := odurum;
                  RETURN;
               END IF;
            END IF;
         END IF;
      END;

      IF v_abone_stb_tipi = 'TK' AND v_type = 'SC' THEN
         BEGIN
            SELECT sozlesme_no
              INTO v_sozlesme_no
              FROM yk_dp_kontrat
             WHERE uye_no = iuye_no AND outlet_location = ioutlet_location AND status = 30;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_sozlesme_no := NULL;
         END;

         IF in_sozlesme_no IS NOT NULL THEN
            IF v_sozlesme_no IS NOT NULL THEN
               v_tk_kart_no := tk_pack.tk_kartno_bul (v_sozlesme_no, 'TK');

               IF iserial_number <> v_tk_kart_no OR TRIM (v_tk_kart_no) IS NULL THEN
                  IF yetki_pack.yetkisi_varmi (igiren_kullanici, 'ISLEM_ZAP_KART_FARKLI_EKIPMAN_GIRISI') = 0 THEN
                     odurum      := 'BU ÜYENIN SÖZLESMESI ILE EKIPMANI UYUSMAMAKTADIR.(' || v_sozlesme_no || ')';
                     oproc_name  := 'EKIPMAN_EKLE_CIKAR';
                     oerror_type := 1;
                     oerror_code := 'ERR362';
                     oerror_text := odurum;
                     RETURN;
                  END IF;
               END IF;
            END IF;
         ELSE
            SELECT COUNT (1)
              INTO v_count
              FROM stok_dba.s_eslenik_zapkart
             WHERE sc = iserial_number AND sozlesme <> NVL (v_sozlesme_no, 'XXX') AND eslenik_aktif = 'Y';

            IF v_count > 0 THEN
               odurum      := 'BU KART BASKA BIR SÖZLESME ILE ESLESMISTIR. UYEYE VERILEMEZ';
               oproc_name  := 'EKIPMAN_EKLE_CIKAR';
               oerror_type := 1;
               oerror_code := 'ERR364';
               oerror_text := odurum;
               RETURN;
            END IF;
         END IF;
      END IF;

      abone_islem_pack.abone_islem (v_uye_no, v_sonuc, v_mesaj);

      IF v_sonuc <> '0' THEN
         odurum      := v_mesaj;
         oproc_name  := 'ABONE ISLEM';
         oerror_type := 1;
         oerror_code := 'ERR347';
         oerror_text := odurum;
         RETURN;
      END IF;

      BEGIN
         SELECT customer_status, customer_type, franchise_code, hp_cluster
           INTO v_customer_status, v_customer_type, v_franchise_code, v_abone_stb_tipi
           FROM wiz_customer_hp_life
          WHERE account_number = v_uye_no;
      EXCEPTION
         WHEN OTHERS THEN
            odurum      := 'UYE STATU BILGISI ELDE EDILEMEDI';
            oproc_name  := 'EKIPMAN EKLE';
            oerror_type := 1;
            oerror_code := 'ERR351';
            oerror_text := odurum;
            RETURN;
      END;

      IF     v_customer_status = 'IN'
         AND (ikontratsiz_aktifleme = 'Y' OR (iotel_mi = 'Y' AND v_type = 'SC' AND uye_kontrol_pack.outlet_aktif_mi (iuye_no, ioutlet_location) = 0)) THEN
         v_islem_tipi := 2; --yeni abonelik
      ELSE
         v_islem_tipi := 1; --ekipman ekle çikar
      END IF;

      BEGIN
         SELECT wiz_employee_code, wiz_operator_id
           INTO v_wiz_employee_code, v_wiz_operator_id
           FROM co_kullanici
          WHERE kod = igiren_kullanici;
      EXCEPTION
         WHEN OTHERS THEN
            odurum      := 'KULLANICI EMPLOYEE KODU VE OPERATOR ID ELDE EDILEMEDI';
            oproc_name  := 'EKIPMAN EKLE';
            oerror_type := 1;
            oerror_code := 'ERR347';
            oerror_text := odurum;
            RETURN;
      END;

      kilit_pack.ekipman_kilit (iserial_number, v_sonuc);

      IF v_sonuc <> '0' THEN
         odurum      := 'SEÇTIGINIZ KAYIT BASKA BIRISI TARAFINDA AÇILMISTIR.LÜTFEN DAHA SONRA TEKRAR DENEYINIZ.';
         oproc_name  := 'EKIPMAN KILIT';
         oerror_type := 1;
         oerror_code := 'ERR352';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF v_type = 'SC' THEN
         -- Channel Map Kart için bir havadan aktivasyon var ise iptal edilir.
         BEGIN
            UPDATE dbs_addr_on_air_activation
               SET beklenen_kapanma_tarihi = SYSDATE
             WHERE serial_number = iserial_number AND NVL (account_number, 0) = 0 AND outlet_location IS NULL;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               odurum      := 'HAVADAN AKTIVASYON IPTALINDE HATA OLUSTU';
               oproc_name  := 'HAVADAN AKTIVASYON IPTAL';
               oerror_type := 1;
               oerror_code := 'ERR347';
               oerror_text := 'HAVADAN AKTIVASYON IPTALINDE HATA OLUSTU';
               RETURN;
         END;
      END IF;

      --MKECECI - 23.10.2014 - bu bloğa gerek yok
      --      DECLARE
      --         v_tmp_uye_no               NUMBER;
      --         v_tmp_outlet_location      VARCHAR2 (3);
      --         v_tmp_service_address_id   NUMBER;
      --         v_tmp_old_lokasyon         wiz_equip.equip_location_code%TYPE;
      --      BEGIN
      --         v_tmp_uye_no := v_uye_no;
      --         v_tmp_outlet_location := v_outlet_location;
      --         v_tmp_service_address_id := v_service_address_id;
      --         work_order_pack.addr_get_equip_value (v_sc_ekipman_no,
      --                                               v_tmp_uye_no,
      --                                               v_tmp_service_address_id,
      --                                               v_tmp_outlet_location,
      --                                               v_channel_map_1,
      --                                               v_channel_map_2,
      --                                               v_channel_map_3,
      --                                               v_channel_map_4,
      --                                               v_ppv_purchase_current_limit,
      --                                               v_tmp_old_lokasyon, --v_old_lokasyon,
      --                                               v_sonuc);
      --
      --         IF v_sonuc <> '0'
      --         THEN
      --            odurum := v_sonuc;
      --            oproc_name := 'ADDR GET EQUIP VALUE';
      --            oerror_type := 1;
      --            oerror_code := 'ERR347';
      --            oerror_text := odurum;
      --            RETURN;
      --         END IF;
      --      END;
      v_channel_map_2              := 0;
      v_channel_map_3              := 0;
      v_channel_map_4              := 0;
      v_ppv_purchase_current_limit := 0;
      --</end> MKECECI - 23.10.2014

      work_order_pack.work_order_insert (iuye_no, iservice_address_id, v_wiz_employee_code, ibayi_kodu, v_islem_tipi, v_work_order_number, v_sonuc);

      IF v_sonuc <> '0' THEN
         odurum      := 'WORK ORDER INSERT:' || v_sonuc;
         oproc_name  := 'WORK ORDER INSERT';
         oerror_type := 1;
         oerror_code := 'ERR347';
         oerror_text := odurum;
         RETURN;
      END IF;

      ekipman_pack.wiz_equip_to_abone_insert (iserial_number,
                                              v_work_order_number,
                                              ioutlet_location,
                                              ibayi_kodu,
                                              'H',
                                              v_wiz_operator_id,
                                              v_trx_tarih,
                                              v_sonuc,
                                              ireason_code
                                             );

      IF v_sonuc <> '0' THEN
         odurum      := v_sonuc;
         oproc_name  := 'WIZ EQUIP TO ABONE INSERT';
         oerror_type := 1;
         oerror_code := 'ERR347';
         oerror_text := odurum;
         RETURN;
      END IF;

      /*--- Evren --- 20111215 --- begin ---*/
      IF v_type = 'ST' AND v_abone_stb_tipi <> 'BB' THEN
         /*bozturkmen ekipman eklerken 2 aşamalı kontrol yapıyoruz, önce sadece servis bağımsız ekipman uyumu*/
         rama_servis.servisekipmanuyum (v_uye_no,
                                        v_outlet_location,
                                        NULL,
                                        igiren_kullanici,
                                        oerror_text,
                                        odurum,
                                        oerror_type,
                                        oerror_code,
                                        v_servis_dusur,
                                        'EKIPMAN_EKLEME'
                                       );

         IF odurum <> '0' THEN
            oproc_name  := 'SERVISEKIPMANUYUM';
            oerror_type := 1;
            oerror_code := 'ERR123'; /*TODO: Hata kodu üret*/
            oerror_text := odurum;
            RETURN;
         END IF;

         /*bozturkmen abonenin üzerindeki servislerin ve add work itemların ekipmanla uyumu*/
         FOR rec_
            IN (SELECT 'SVC' AS itemtype, service_code, servis_frekansi, campaign_code
                  FROM dt_dbs_int_dba.vv_uye_ittp_servisler
                 WHERE account_number = v_uye_no AND outlet_location = v_outlet_location
                UNION
                SELECT 'WO' AS itemtype, service_code, servis_frekansi, campaign_code
                  FROM dt_dbs_int_dba.vv_ittp_customer_order
                 WHERE     job_code = 'ADD'
                       AND work_order_statu IN ('ACIK') --, 'BEKLEMEDE')
                       AND havadan_flag = 0
                       AND work_line_statu = 'ACIK'
                       AND dbs_account_number = v_uye_no
                       AND dbs_outlet_location = v_outlet_location) LOOP
            rama_servis.servisekipmanuyum (v_uye_no,
                                           v_outlet_location,
                                           rec_.service_code,
                                           igiren_kullanici,
                                           oerror_text,
                                           odurum,
                                           oerror_type,
                                           oerror_code,
                                           v_servis_dusur,
                                           'SERVIS_EKLEME'
                                          );

            IF odurum <> '0' THEN
               /*bozturkmen uyumsuz olan servis work item ile eklenecek bir servisse, hata veriyoruz*/
               /*  if rec_.itemtype = 'WO' then
                 begin
                   select substr(offer_cd,1,3) into v_servis_hatirlat from dt_product_api.vw_service_res_convenience  where type = '3' and dbs_eq_ekipman_tip_matrix_id = v_ekipman_tip_matrix_id and sahiplik_tipi = rama_servis.get_resource_ownership_type(iserial_number)  and substr(trim(offer_cd),-2,2) = v_abone_stb_tipi;
                    oerror_type := 1;
                    oerror_code := 'ERR1204';
                    oerror_text := 'Aboneye tanımlı iş emirlerinde bu ekipmanla uyumsuz bir servis var, ' || rec_.service_code || ' yerine ' || v_servis_hatirlat || ' eklemeyi deneyin.';
                    odurum:= oerror_text;
                    return;
                   exception when no_data_found then
                    oerror_type := 1;
                    oerror_code := 'ERR1204';
                    oerror_text := 'Aboneye tanımlı iş emirlerinde bu ekipmanla uyumsuz bir servis var : ' || rec_.service_code;
                    odurum:=oerror_text;
                    return;
                 end;
                 end if;*/
               IF rec_.itemtype = 'WO' THEN
                  oerror_type := 1;
                  oerror_code := 'ERR1204';
                  oerror_text := 'Aboneye tanımlı iş emirlerinde bu ekipmanla uyumsuz bir servis var, iş emrini silerek tekrar deneyin';
                  odurum      := oerror_text;
                  RETURN;
               END IF;

               IF v_servis_dusur = 'E' THEN
                  NULL;
               ELSE
                  oproc_name := 'EKIPMAN EKLE';
                  RETURN;
               END IF;
            END IF;
         END LOOP;
      END IF;

      /*--- Evren --- 20111215 --- end ---*/
      ekipman_pack.ekipman_log_insert (iserial_number,
                                       iuye_no,
                                       ioutlet_location,
                                       in_sozlesme_no,
                                       ibayi_kodu,
                                       idepoya,
                                       v_old_lokasyon,
                                       ireason_code,
                                       its_form_no,
                                       igiren_kullanici,
                                       v_work_order_number,
                                       v_trx_tarih,
                                       in_otorizasyon_no,
                                       in_ts_sifre_id,
                                       in_aciklama,
                                       v_sonuc
                                      );

      IF v_sonuc <> '0' THEN
         odurum      := v_sonuc;
         oproc_name  := 'EKIPMAN LOG INSERT';
         oerror_type := 1;
         oerror_code := 'ERR347';
         oerror_text := odurum;
         RETURN;
      END IF;

      SELECT COUNT (1)
        INTO v_count
        FROM mb_outlet_takip
       WHERE account_number = iuye_no AND outlet_location = ioutlet_location;

      --MKECECI-26.12.2014 kontratsız aktiflemede kart eklenirken check box işaretli olmazsa outlet yaratılmıyordu.
      IF    ikontratsiz_aktifleme = 'Y'
         OR (iotel_mi = 'Y' AND v_type = 'SC' AND uye_kontrol_pack.outlet_aktif_mi (iuye_no, ioutlet_location) = 0)
         OR (v_count = 0 AND v_type = 'SC' AND ireason_code <> 'YKO') THEN
         ekipman_pack.kontratsiz_aktif_yapilabilir (iuye_no, iserial_number, ioutlet_location, igiren_kullanici, v_sonuc);

         IF v_sonuc <> '0' THEN
            odurum      := v_sonuc;
            oproc_name  := 'KONTRATSIZ AKTIF YAPILABILIR';
            oerror_type := 1;
            oerror_code := 'ERR347';
            oerror_text := odurum;
            RETURN;
         END IF;

         IF v_type = 'SC' THEN
            sms_yeni_kontrat_pack.mb_outlet_takip_insert (iuye_no, v_work_order_number, ioutlet_location, 'KAK', igiren_kullanici, v_sonuc);

            IF v_sonuc <> '0' THEN
               odurum      := v_sonuc;
               oproc_name  := 'MB OUTLET TAKIP INSERT';
               oerror_type := 1;
               oerror_code := 'ERR347';
               oerror_text := odurum;
               RETURN;
            END IF;

            /* Begin ITTP Integration - MGOKSU*/
            billing_dbs_int.onl_customer_ittp_pkg.outlet_crt_sp (i_dbs_account_number  => iuye_no,
                                                                 i_dbs_outlet_location => ioutlet_location,
                                                                 o_result_type         => v_result_type,
                                                                 o_result_code         => v_result_code,
                                                                 o_result_message      => v_result_message
                                                                );

            IF v_result_type = 1 THEN
               odurum := v_result_message;
               RETURN;
            END IF;

            --DTVCALOGLU 18.03.2014 <BEGIN>
            DECLARE
               v_uydu_tipi_count         NUMBER;
               v_prt_role_acc_id         NUMBER;
               v_kullanici_id            NUMBER;
               v_otel_ilk_outlet_kontrol NUMBER := 0;
            BEGIN
               v_prt_role_acc_id      := billing_dbs_int.customer_ittp_pkg.get_service_account_id (i_dbs_account_number  => iuye_no,
                                                                                                   i_dbs_outlet_location => ioutlet_location
                                                                                                  );

               SELECT COUNT (1)
                 INTO v_uydu_tipi_count
                 FROM dt_party_dba.party_role_acc_char_value v
                WHERE     v.party_role_account_id = v_prt_role_acc_id
                      AND v.char_spec_use_id = 21064
                      AND v.lov_table_row_cd IS NOT NULL
                      AND SYSDATE BETWEEN v.valid_from AND v.valid_thru;

               IF v_uydu_tipi_count = 0 THEN
                  FOR rec
                     IN (SELECT v.lov_table_row_cd
                           FROM dt_party_dba.party_role_acc_char_value v,
                                dt_party_dba.party_role_account pra
                          WHERE     pra.party_role_account_id = v.party_role_account_id
                                AND char_spec_use_id = 21064
                                AND v.lov_table_row_cd IS NOT NULL
                                AND SYSDATE BETWEEN v.valid_from AND v.valid_thru
                                AND pra.dbs_account_number = iuye_no
                                AND pra.dbs_outlet_location =
                                       (SELECT MIN (pra.dbs_outlet_location) AS min_outlet
                                          FROM dt_party_dba.party_role_acc_char_value v,
                                               dt_party_dba.party_role_account pra
                                         WHERE     pra.party_role_account_id = v.party_role_account_id
                                               AND char_spec_use_id = 21064
                                               AND v.lov_table_row_cd IS NOT NULL
                                               AND SYSDATE BETWEEN v.valid_from AND v.valid_thru
                                               AND pra.dbs_account_number = iuye_no
                                               AND pra.dbs_outlet_location <> ioutlet_location)) LOOP
                     v_kullanici_id            := TO_CHAR (dt_dbs_int_api.dbs_to_ittp_pkg.get_login_id_fn (igiren_kullanici, NULL, NULL));
                     v_otel_ilk_outlet_kontrol := 1;
                     dt_crm_api.party_char_pkg.account_set_sp (i_account_id       => v_prt_role_acc_id,
                                                               i_char_spec_use_cd => 'UYDU_TIPI',
                                                               i_char_value       => rec.lov_table_row_cd,
                                                               i_creation_date    => SYSDATE,
                                                               i_created_by       => v_kullanici_id,
                                                               i_update_date      => SYSDATE,
                                                               i_updated_by       => v_kullanici_id
                                                              );
                  END LOOP;

                  IF v_otel_ilk_outlet_kontrol = 0 THEN
                     IF (iotel_mi = 'Y' AND v_type = 'SC') THEN
                        dt_crm_api.party_char_pkg.account_set_sp (i_account_id       => v_prt_role_acc_id,
                                                                  i_char_spec_use_cd => 'UYDU_TIPI',
                                                                  i_char_value       => 'EUTELSAT',
                                                                  i_creation_date    => SYSDATE,
                                                                  i_created_by       => v_kullanici_id,
                                                                  i_update_date      => SYSDATE,
                                                                  i_updated_by       => v_kullanici_id
                                                                 );
                     END IF;
                  END IF;
               END IF;
            END;
         --DTVCALOGLU 18.03.2014 <END>

         /* End ITTP Integration */
         END IF;
      END IF;

      -- Falamur 02092014 sinyal sıralamasında değişiklik. Sinyaller her zaman kart kutu varken birlikte çıksın.
      IF (   (v_irdetodestekliekipman = 'H' AND v_type = 'SC') -- Cryripto için kontroller
          OR (    v_irdetodestekliekipman = 'E'
              AND v_sc_ekipman_no NOT IN ('-1', '-2')
              AND (v_st_ekipman_no NOT IN ('-1', '-2') OR v_md_ekipman_no NOT IN ('-1', '-2'))) --irdeto için kontroller
                                                                                               ) THEN
         v_channel_map_1 := 0;
         -- IF v_type = 'SC' THEN
         work_order_pack.equip_changes (v_sc_ekipman_no,
                                        v_channel_map_1,
                                        v_channel_map_2,
                                        v_channel_map_3,
                                        v_channel_map_4,
                                        v_ppv_purchase_current_limit,
                                        NULL,
                                        NULL,
                                        SYSDATE,
                                        igiren_kullanici,
                                        v_sonuc
                                       );

         IF v_sonuc <> '0' THEN
            odurum      := v_sonuc;
            oproc_name  := 'EQUIP CHANGES';
            oerror_type := 1;
            oerror_code := 'ERR347';
            oerror_text := odurum;
            RETURN;
         END IF;

         -- END IF;

         ---------------------------------------------
         --oppv kontrol ve ISlemlerI
         ---------------------------------------------
         /* 31032010 falamur  Sadece kart için bu sinyaller çıkacaktır. */
         --IF v_type = 'SC' THEN
         film_istek_pack.film_istek_diger_islemler (iuye_no, ioutlet_location, v_sc_ekipman_no, 2, igiren_kullanici, v_sonuc);

         IF v_sonuc <> '0' THEN
            odurum      := v_sonuc;
            oproc_name  := 'FILM_ISTEK_DIGER_ISLEMLER';
            oerror_type := 1;
            oerror_code := 'ERR347';
            oerror_text := odurum;
            RETURN;
         END IF;
      END IF;

      IF ikontratsiz_aktifleme = 'Y' THEN
         abone_outlet_statu_pack.outlet_statu_update (iuye_no,
                                                      ioutlet_location,
                                                      igiren_kullanici,
                                                      SYSDATE,
                                                      p_statu,
                                                      p_eski_statu,
                                                      p_detay_statu,
                                                      p_return_status
                                                     );

         IF p_return_status <> '0' THEN
            odurum      := 'ABONE STATU PROBLEMI ' || p_return_status;
            oproc_name  := 'EKIPMAN EKLE';
            oerror_type := 1;
            oerror_code := 'ERR347';
            oerror_text := odurum;
            RETURN;
         END IF;
      END IF;

      /*
      Ekipman  eklemede özellik kodu kontrolu :
      Bu kontrol,  mutabakat sirasinda ts lerin elinde bulunan kartlari üyeye vermemeleri için yapildi..
      */
      IF dbs_sabit ('KULLANILABILIR_EKIPMAN_KONTROLU') = 'E' THEN
         ekipman_ozellik_pack.ekipman_ozellik_sil (iserial_number, dbs_sabit ('KULLANILABILIR_EKIPMAN_OZELLIK'), igiren_kullanici, v_sonuc);

         IF v_sonuc <> '0' THEN
            odurum      := v_sonuc;
            oproc_name  := 'ekipman_ozellik_sil';
            oerror_type := 1;
            oerror_code := 'ERR462';
            oerror_text := 'EKIPMAN OZELLIK DEGISTIRME ISLEMI YAPILAMADI';
            RETURN;
         END IF;
      END IF;

      IF in_ts_guncel_isl = 'E' THEN
         IF ikontratsiz_aktifleme = 'Y' THEN
            bt_uye_ts_pack.bt_uye_ts_guncel_feed (iuye_no,
                                                  ioutlet_location,
                                                  ibayi_kodu,
                                                  5, --IN_YTS_ISLEM_TIPI
                                                  'C', --IN_STATUS
                                                  NULL, --IN_MEMO_KOD,
                                                  NULL, --IN_SEBEP_KOD,
                                                  5, --IN_EKRAN_KOD
                                                  igiren_kullanici,
                                                  'KONTRATSIZ AKTIFLEME',
                                                  v_sonuc
                                                 );

            IF v_sonuc <> '0' THEN
               odurum      := v_sonuc;
               oproc_name  := 'BT_UYE_TS_GUNCEL_FEED';
               oerror_type := 1;
               oerror_code := 'ERR396';
               oerror_text := 'GÜNCEL TS ISLEMLERI YAPILAMADI';
               RETURN;
            END IF;
         ELSE
            bt_uye_ts_pack.bt_uye_ts_guncel_feed (iuye_no, ioutlet_location, ibayi_kodu, 3, --IN_YTS_ISLEM_TIPI
                                                                                           'C', --IN_STATUS
                                                                                               NULL, --IN_MEMO_KOD,
                                                                                                    NULL, --IN_SEBEP_KOD,
                                                                                                         4, --IN_EKRAN_KOD
                                                                                                           igiren_kullanici, 'EKIPMAN EKLEME', v_sonuc);

            IF v_sonuc <> '0' THEN
               odurum      := v_sonuc;
               oproc_name  := 'BT_UYE_TS_GUNCEL_FEED';
               oerror_type := 1;
               oerror_code := 'ERR396';
               oerror_text := 'GÜNCEL TS ISLEMLERI YAPILAMADI';
               RETURN;
            END IF;
         END IF;
      END IF;

      odurum                       := v_sonuc;
      ois_emri                     := v_work_order_number;
      DBMS_APPLICATION_INFO.set_module (NULL, NULL);
   EXCEPTION
      WHEN OTHERS THEN
         odurum      := odurum || SQLERRM;
         oproc_name  := 'ekipman_pack.ekipman_ekle';
         oerror_type := 1;
         oerror_code := 'ERR346';
         oerror_text := odurum;
   END ekipman_ekle;

   PROCEDURE ekipman_cikar (iuye_no             IN     wiz_equip.account_number%TYPE,
                            iserial_number      IN     wiz_equip.serial_number%TYPE,
                            ioutlet_location    IN     wiz_equip.outlet_location%TYPE,
                            ibayi_kodu          IN     lg_ekipman.sales_agent_code%TYPE,
                            its_form_no         IN     tf_teknik_servis_formu.seri_no%TYPE,
                            ireason_code        IN     lg_ekipman.reason_code%TYPE,
                            idepoya             IN     lg_ekipman.depoya%TYPE,
                            iservice_address_id IN     wiz_customer_hp_life.service_address_id%TYPE,
                            igiren_kullanici    IN     co_kullanici.kod%TYPE,
                            in_otorizasyon_no   IN     lg_ekipman.otorizasyon_no%TYPE,
                            in_ts_sifre_id      IN     lg_ekipman.lg_teknik_servis_sifre_id%TYPE,
                            in_aciklama         IN     lg_ekipman.aciklama%TYPE,
                            odurum                 OUT VARCHAR2,
                            out_taa_uyari          OUT VARCHAR2,
                            oproc_name             OUT VARCHAR2,
                            ois_emri               OUT VARCHAR2,
                            oerror_type            OUT NUMBER,
                            oerror_code            OUT VARCHAR2,
                            oerror_text            OUT VARCHAR2
                           ) IS
      /*OGM ittp integration variables*/
      v_ittp_result_type           NUMBER;
      v_ittp_result_code           VARCHAR2 (512);
      v_ittp_result_message        VARCHAR2 (32000);
      /*OGM ittp integration variables*/
      v_count                      NUMBER (3);
      v_sonuc                      VARCHAR2 (512);
      v_mesaj                      VARCHAR2 (512);
      v_taa_uyari_mesaji           VARCHAR2 (512);
      v_taa_sonuc                  VARCHAR2 (512) := '0';
      v_customer_status            VARCHAR2 (2);
      v_islem_tipi                 NUMBER (2);
      v_type                       VARCHAR2 (2);
      v_campaign_code              VARCHAR2 (3);
      v_uye_no                     wiz_equip.account_number%TYPE;
      v_old_lokasyon               wiz_equip.equip_location_code%TYPE;
      v_service_address_id         wiz_customer_hp_life.service_address_id%TYPE;
      v_outlet_location            wiz_equip.outlet_location%TYPE;
      v_channel_map_1              wiz_equip.channel_map_1%TYPE;
      v_channel_map_2              wiz_equip.channel_map_2%TYPE;
      v_channel_map_3              wiz_equip.channel_map_3%TYPE;
      v_channel_map_4              wiz_equip.channel_map_4%TYPE;
      v_ppv_purchase_current_limit wiz_equip.ppv_purchase_current_limit%TYPE;
      v_work_order_number          NUMBER (10); --wiz_work_order.work_order_number%TYPE;
      v_trx_tarih                  wiz_equip_trx.trx_date%TYPE;
      v_id                         mb_outlet_takip.id%TYPE;
      v_wiz_employee_code          co_kullanici.wiz_employee_code%TYPE;
      v_ekipman_account_number     wiz_equip.account_number%TYPE;
      v_wiz_operator_id            co_kullanici.wiz_operator_id%TYPE;
      v_outlet_in_tarihi           mb_outlet_takip.outlet_in_tarihi%TYPE;
      v_manufacturer               wiz_equip.manufacturer%TYPE;
      v_uyari_mesaji               VARCHAR2 (512);
      v_hos_paket_uyesi            DATE;
      v_statu                      mb_abone_statu.statu%TYPE;
      v_eski_statu                 mb_abone_statu.eski_statu%TYPE;
      v_detay_statu                mb_abone_statu.detay_statu%TYPE;
      v_disconnect_reason_code     CHAR (3);
      v_iptal_talebi_id            NUMBER (10);
      v_taa_uyari                  VARCHAR2 (512);
      v_bayi_durum                 bt_bayi_teknik_servis.durum_kodu%TYPE;
      v_depo_durum                 wiz_equip_location_codes.assignable%TYPE;
      v_cust_type_count            NUMBER;
      v_statu_count                NUMBER;
      v_islem_count                NUMBER;
      v_hp_life_in_yap             NUMBER (1);
      v_ittp_order_int_open        NUMBER;

      CURSOR acik_wo_var_mi ( --DEĞİŞMEYECEK
                             wo_no NUMBER /*wiz_work_order.work_order_number%TYPE*/
                                         ) IS
         SELECT w.work_order_number
           FROM wiz_work_order w
          WHERE     w.work_order_number = wo_no
                AND w.wo_status IN ('O', 'P')
                AND NOT EXISTS
                       (SELECT 1
                          FROM wiz_wo_line_items wl
                         WHERE wl.wo_status = 'O' AND wl.work_order_number = w.work_order_number);

      acik_wo_var_mi_rec           acik_wo_var_mi%ROWTYPE;
      v_depoya                     wiz_equip.equip_location_code%TYPE;
   -----------------------------------------------------------------------
   BEGIN
      odurum                   := '0';
      oerror_type              := 0;
      oerror_code              := 'VLD348';
      oerror_text              := NULL;
      v_uye_no                 := TRIM (iuye_no);
      v_outlet_location        := TRIM (ioutlet_location);
      v_service_address_id     := TRIM (iservice_address_id);
      v_depoya                 := TRIM (idepoya);
      v_ittp_order_int_open    := billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT');

      IF LTRIM (iuye_no) IS NULL THEN
         odurum      := 'UYE NO BILGISI BOS';
         oproc_name  := 'EKIPMAN CIKAR';
         oerror_type := 1;
         oerror_code := 'ERR351';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF LTRIM (iserial_number) IS NULL THEN
         odurum      := 'EKIPMAN NO BILGISI BOS';
         oproc_name  := 'EKIPMAN CIKAR';
         oerror_type := 1;
         oerror_code := 'ERR351';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF LTRIM (ioutlet_location) IS NULL THEN
         odurum      := 'OUTLET BILGISI BOS.' || iserial_number;
         oproc_name  := 'EKIPMAN CIKAR';
         oerror_type := 1;
         oerror_code := 'ERR351';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF LTRIM (ibayi_kodu) IS NULL THEN
         odurum      := 'BAYI KODU BILGISI BOS';
         oproc_name  := 'EKIPMAN CIKAR';
         oerror_type := 1;
         oerror_code := 'ERR365';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF LTRIM (ireason_code) IS NULL THEN
         odurum      := 'SEBEP KODU BILGISI BOS';
         oproc_name  := 'EKIPMAN CIKAR';
         oerror_type := 1;
         oerror_code := 'ERR347';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF LTRIM (iservice_address_id) IS NULL THEN
         odurum      := 'ADRES ID BILGISI BOS';
         oproc_name  := 'EKIPMAN CIKAR';
         oerror_type := 1;
         oerror_code := 'ERR347';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF LTRIM (igiren_kullanici) IS NULL THEN
         odurum      := 'KULLANICI BILGISI BOS';
         oproc_name  := 'EKIPMAN CIKAR';
         oerror_type := 1;
         oerror_code := 'ERR347';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF TRIM (v_depoya) IS NOT NULL THEN
         kategori_yetki_var_mi (igiren_kullanici, TRIM (v_depoya), NULL, 'UAL', odurum);

         IF SUBSTR (odurum, 1, 3) != 'VAR' THEN
            odurum      := 'BU EKIPMANI BU DEPOYA ATMA YETKINIZ YOK.';
            oproc_name  := 'EKIPMAN CIKAR';
            oerror_type := 1;
            oerror_code := 'ERR356';
            oerror_text := odurum;
            RETURN;
         END IF;

         --<OGM desc="atılan depo ve bayi aktif olmalıdır">
         BEGIN
            --her deponun bayisi olmayabilir.
            SELECT bt.durum_kodu, eq.assignable
              INTO v_bayi_durum, v_depo_durum
              FROM bt_bayi_teknik_servis bt,
                   wiz_equip_location_codes eq
             WHERE eq.equip_location_code = bt.depo_kodu(+) AND eq.equip_location_code = v_depoya;

            IF v_bayi_durum = 3 AND yetki_pack.yetkisi_varmi (igiren_kullanici, 'ISLEM_IN_BAYIYE_EKIPMAN_ATMA') = 0 THEN
               odurum      := 'BU EKIPMANI BU DEPOYA ATMA YETKINIZ YOK..';
               oproc_name  := 'EKIPMAN CIKAR';
               oerror_type := 1;
               oerror_code := 'ERR356';
               oerror_text := odurum;
               RETURN;
            END IF;

            IF v_depo_durum = 'N' AND yetki_pack.yetkisi_varmi (igiren_kullanici, 'ISLEM_IN_DEPOYA_EKIPMAN_ATMA') = 0 THEN
               odurum      := 'BU EKIPMANI BU DEPOYA ATMA YETKINIZ YOK...';
               oproc_name  := 'EKIPMAN CIKAR';
               oerror_type := 1;
               oerror_code := 'ERR356';
               oerror_text := odurum;
               RETURN;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               odurum      := 'BU EKIPMANI BU DEPOYA ATMA YETKINIZ YOK....';
               oproc_name  := 'EKIPMAN CIKAR';
               oerror_type := 1;
               oerror_code := 'ERR356';
               oerror_text := odurum;
               RETURN;
         END;
      --</OGM>
      END IF;

      abone_islem_pack.abone_islem (v_uye_no, v_sonuc, v_mesaj);

      IF v_sonuc <> '0' THEN
         odurum      := v_mesaj;
         oproc_name  := 'EKIPMAN CIKAR:ABONE ISLEM';
         oerror_type := 1;
         oerror_code := 'ERR352';
         oerror_text := odurum;
         RETURN;
      END IF;

      BEGIN
         SELECT customer_status
           INTO v_customer_status
           FROM wiz_customer_hp_life
          WHERE account_number = v_uye_no;
      EXCEPTION
         WHEN OTHERS THEN
            odurum      := 'UYE STATU BILGISI ELDE EDILEMEDI';
            oproc_name  := 'EKIPMAN CIKAR';
            oerror_type := 1;
            oerror_code := 'ERR351';
            oerror_text := odurum;
            RETURN;
      END;

      BEGIN
         SELECT wiz_employee_code, wiz_operator_id
           INTO v_wiz_employee_code, v_wiz_operator_id
           FROM co_kullanici
          WHERE kod = igiren_kullanici;
      EXCEPTION
         WHEN OTHERS THEN
            odurum      := 'KULLANICI EMPLOYEE KODU ELDE EDILEMEDI';
            oproc_name  := 'EKIPMAN CIKAR';
            oerror_type := 1;
            oerror_code := 'ERR347';
            oerror_text := odurum;
            RETURN;
      END;

      BEGIN
         SELECT converter_type, equip_location_code, account_number, manufacturer
           INTO v_type, v_old_lokasyon, v_ekipman_account_number, v_manufacturer
           FROM wiz_equip
          WHERE serial_number = iserial_number;

         IF v_ekipman_account_number = '0' THEN
            odurum      := 'EKIPMAN ZATEN BIR ÜYE ÜZERINDE DEGIL ISLEM YAPILAMAZ';
            oproc_name  := 'EKIPMAN CIKAR';
            oerror_type := 1;
            oerror_code := 'ERR353';
            oerror_text := odurum;
            RETURN;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            odurum      := 'EKIPMAN SISTEMDE YOK';
            oproc_name  := 'EKIPMAN CIKAR';
            oerror_type := 1;
            oerror_code := 'ERR354';
            oerror_text := odurum;
            RETURN;
      END;

      IF TRIM (kontrol_pack.btv_karti_mi (igiren_kullanici, iserial_number)) IS NOT NULL THEN
         odurum      := 'EKIPMAN BTV KARTI OLARAK TANIMLI.KART ÜYEDEN ALINAMAZ.';
         oproc_name  := 'EKIPMAN CIKAR';
         oerror_type := 1;
         oerror_code := 'ERR355';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF TRIM (v_manufacturer) = 'VS' THEN
         IF yetki_pack.yetkisi_varmi (igiren_kullanici, 'ISLEM_VESTEL_STB_DUSURME') = 0 THEN
            odurum      := 'BU VESTEL EKIPMANINI DÜSÜRME YETKINIZ YOK.';
            oproc_name  := 'EKIPMAN CIKAR';
            oerror_type := 1;
            oerror_code := 'ERR356';
            oerror_text := odurum;
            RETURN;
         END IF;
      -- turk yok  VSK ya gondermek yok
      --v_depoya := 'VSK';--mutlu söyledi
      ELSE
         IF LTRIM (v_depoya) IS NULL THEN
            odurum      := 'DEPO BILGISI BOS';
            oproc_name  := 'EKIPMAN CIKAR';
            oerror_type := 1;
            oerror_code := 'ERR347';
            oerror_text := odurum;
            RETURN;
         END IF;
      END IF;

      --islem yapilacak ekipmani kIlItle
      kilit_pack.ekipman_kilit (iserial_number, v_sonuc);

      IF v_sonuc <> '0' THEN
         odurum      := 'SEÇTIGINIZ KAYIT BASKA BIRISI TARAFINDA AÇILMISTIR.LÜTFEN DAHA SONRA TEKRAR DENEYINIZ.';
         oproc_name  := 'EKIPMAN KILIT';
         oerror_type := 1;
         oerror_code := 'ERR352';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF v_type = 'SC' THEN
         work_order_pack.addr_get_equip_value (iserial_number,
                                               v_uye_no,
                                               v_service_address_id,
                                               v_outlet_location,
                                               v_channel_map_1,
                                               v_channel_map_2,
                                               v_channel_map_3,
                                               v_channel_map_4,
                                               v_ppv_purchase_current_limit,
                                               v_old_lokasyon,
                                               v_sonuc
                                              );

         IF v_sonuc <> '0' THEN
            odurum      := v_sonuc;
            oproc_name  := 'ADDR GET EQUIP VALUE';
            oerror_type := 1;
            oerror_code := 'ERR347';
            oerror_text := odurum;
            RETURN;
         END IF;

         v_uye_no             := iuye_no;
         v_outlet_location    := ioutlet_location;
         v_service_address_id := iservice_address_id;
      END IF;

      v_islem_tipi             := 1; --ekipman ekle çikar
      v_disconnect_reason_code := '   ';

      IF v_type = 'SC' THEN
         abone_outlet_statu_pack.outlet_statu_update (iuye_no, v_outlet_location, igiren_kullanici, SYSDATE, v_statu, v_eski_statu, v_detay_statu, v_sonuc);

         IF v_sonuc <> '0' THEN
            odurum      := 'ABONE STATU PROBLEMI ' || v_sonuc;
            oproc_name  := 'EKIPMAN CIKAR';
            oerror_type := 1;
            oerror_code := 'ERR347';
            oerror_text := odurum;
            RETURN;
         END IF;

         /********ITTP_INTEGRATION**********************/
         IF v_statu IN ('I', 'K', 'W') THEN
            billing_dbs_int.onl_agreement_ittp_pkg.integrate_agreement (i_dbs_account_number  => iuye_no,
                                                                        i_dbs_outlet_location => v_outlet_location,
                                                                        i_job_code            => 'DSR',
                                                                        i_date                => SYSDATE,
                                                                        i_dbs_user            => igiren_kullanici,
                                                                        o_result_type         => v_ittp_result_type,
                                                                        o_result_code         => v_ittp_result_code,
                                                                        o_result_message      => v_ittp_result_message
                                                                       );

            IF v_ittp_result_type = 1 THEN
               odurum      := v_ittp_result_code || ':' || v_ittp_result_message;
               oproc_name  := 'EKIPMAN CIKAR';
               oerror_type := 1;
               oerror_code := 'ERR346';
               oerror_text := odurum;
               RETURN;
            END IF;
         END IF;

         /********ITTP_INTEGRATION**********************/
         IF v_statu IN ('I', 'N', 'K') THEN
            BEGIN
               SELECT id, outlet_in_tarihi
                 INTO v_id, v_outlet_in_tarihi
                 FROM (SELECT   id, outlet_in_tarihi
                           FROM mb_outlet_takip
                          WHERE account_number = iuye_no AND outlet_location = v_outlet_location
                       ORDER BY id DESC)
                WHERE ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS THEN
                  odurum      := iuye_no || v_outlet_location || ' MB_OUTLET_TAKIP ID DEGERI ELDE EDILEMEDI';
                  oproc_name  := 'EKIPMAN CIKAR';
                  oerror_type := 1;
                  oerror_code := 'ERR347';
                  oerror_text := odurum;
                  RETURN;
            END;

            IF TRIM (v_outlet_in_tarihi) IS NULL THEN
               IF LTRIM (v_id) IS NOT NULL THEN
                  UPDATE mb_outlet_takip
                     SET degistiren_kullanici = igiren_kullanici, degistirme_tarihi = SYSDATE, outlet_in_tarihi = SYSDATE, sebep_in = ireason_code
                   WHERE id = v_id;

                  fatura.taa_taahhut_pack.abone_taahhut_kontrol (v_uye_no, v_outlet_location, 'IN', NULL, igiren_kullanici, out_taa_uyari, v_taa_sonuc);

                  IF v_taa_sonuc <> '0' THEN
                     odurum      := '-FATURA.TAA_TAAHHUT_PACK.ABONE_TAAHHUT_KONTROL: TAAHHÜT ISLEMLERINDE HATA OLUSTU: ' || v_taa_sonuc;
                     oproc_name  := 'EKIPMAN CIKAR';
                     oerror_type := 1;
                     oerror_code := 'ERR833';
                     oerror_text := v_taa_sonuc;
                     RETURN;
                  END IF;

                  IF TRIM (out_taa_uyari) IS NOT NULL THEN
                     IF yetki_pack.yetkisi_varmi (igiren_kullanici, 'ISLEM_KURULUM_TAAHHUT_UYARI_GECME') = 0 THEN
                        odurum      := 'EKIPMAN_PACK.EKIPMAN_CIKAR: Islem yetkiniz yok: ' || out_taa_uyari;
                        oproc_name  := 'EKIPMAN CIKAR';
                        oerror_type := 1;
                        oerror_code := 'ERR833';
                        oerror_text := out_taa_uyari;
                        RETURN;
                     END IF;
                  END IF;

                  fatura.taa_taahhut_pack.abone_taahhut_kontrol (v_uye_no, v_outlet_location, 'II', NULL, igiren_kullanici, v_taa_uyari_mesaji, v_taa_sonuc);

                  IF v_taa_sonuc <> '0' THEN
                     odurum      := '--FATURA.TAA_TAAHHUT_PACK.ABONE_TAAHHUT_KONTROL: TAAHHÜT ISLEMLERINDE HATA OLUSTU: ' || v_taa_sonuc;
                     oproc_name  := 'EKIPMAN CIKAR';
                     oerror_type := 1;
                     oerror_code := 'ERR833';
                     oerror_text := v_taa_sonuc;
                     RETURN;
                  END IF;
               END IF;

               SELECT COUNT (1)
                 INTO v_count
                 FROM mb_outlet_takip
                WHERE account_number = v_uye_no AND outlet_in_tarihi IS NULL;

               IF v_count = 0 THEN
                  -- Abone statu ile ilgili gerekli düzenlemeler eklendi. 26.10.2010 falamur

                  SELECT COUNT (*) -- DEĞİŞMEYECEK
                    INTO v_count
                    FROM wiz_work_order w,
                         (SELECT work_order_number
                            FROM wiz_wo_line_items
                           WHERE outlet_location <> v_outlet_location AND wo_status = 'O' AND job_code = 'ADD') l
                   WHERE w.work_order_number = l.work_order_number AND w.wo_status IN ('P', 'O') AND w.account_number = v_uye_no;

                  v_hos_paket_uyesi        := hos_paket_uyesi_mi (v_uye_no, v_outlet_location);

                  SELECT COUNT (1)
                    INTO v_cust_type_count
                    FROM wiz_customer_hp_life
                   WHERE account_number = v_uye_no AND customer_type NOT IN ('NOR', 'NOK');

                  SELECT COUNT (1)
                    INTO v_statu_count
                    FROM dbs_dba.mb_abone_statu
                   WHERE account_number = v_uye_no AND outlet_location = v_outlet_location AND statu IN ('P', 'I', 'N');

                  SELECT COUNT (1)
                    INTO v_islem_count
                    FROM dbs_dba.mb_abone_statu_islem
                   WHERE     account_number = v_uye_no
                         AND outlet_location = v_outlet_location
                         AND islem_tarihi IS NULL
                         AND TRUNC (beklenen_islem_tarihi) <= TRUNC (SYSDATE);

                  IF    ireason_code = 'BFI'
                     OR ireason_code = 'ILG'
                     OR (yetki_pack.yetkisi_varmi (igiren_kullanici, 'HOS_PAKET_ERKEN_UYELIK_IPTALI') > 0 AND v_hos_paket_uyesi IS NOT NULL)
                     OR v_cust_type_count > 0
                     OR v_statu_count > 0
                     OR v_islem_count > 0 THEN
                     v_hp_life_in_yap := 1;
                  ELSE
                     v_hp_life_in_yap := 0;
                  END IF;

                  IF v_count = 0 AND v_hp_life_in_yap = 1 THEN
                     v_islem_tipi := 7;
                  ELSE
                     v_islem_tipi := 6;
                  END IF;

                  /********************************************************************************************************/

                  --                  v_islem_tipi := 7;                                             --tum outlet Iptal falamur
                  v_disconnect_reason_code := ireason_code;
               END IF;
            END IF;

            --OGM:eger uyenin o outlete yonelik "O" statulu bir iptal kaydi varsa, "V"ye cekilir.
            UPDATE ie_uyelik_iptal ie
               SET durum = 'V', degistiren_kullanici = igiren_kullanici, degistirme_tarihi = SYSDATE
             WHERE ie.account_number = iuye_no AND ie.outlet_location = v_outlet_location AND ie.durum = 'O';
         ELSIF v_statu = 'W' THEN
            v_hos_paket_uyesi := hos_paket_uyesi_mi (iuye_no, v_outlet_location);

            IF v_hos_paket_uyesi IS NOT NULL THEN
               IF yetki_pack.yetkisi_varmi (igiren_kullanici, 'ISLEM_EKIPMAN_DUSUR_HOS_WAIT') = 0 THEN
                  odurum      := 'WAIT hos paket üyelerinin karti düsürülemez.';
                  oerror_type := 1;
                  oerror_code := 'ERR931';
                  oerror_text := odurum;
                  RETURN;
               ELSE
                  SELECT COUNT (*)
                    INTO v_count
                    FROM ie_uyelik_iptal
                   WHERE account_number = v_uye_no AND outlet_location = v_outlet_location AND durum = 'O';

                  IF v_count = 0 THEN
                     uyelik_iptali_pack.uyelik_iptal_insert_update (0,
                                                                    v_uye_no,
                                                                    v_service_address_id,
                                                                    v_outlet_location,
                                                                    'H', -- in_ekipman_sokulecek_mi,
                                                                    NULL, -- in_ekipman_depo_lokasyon,
                                                                    NULL, -- in_work_order_number,
                                                                    NULL, -- in_atanan_ts,
                                                                    NULL, -- in_ts_atanma_tarihi,
                                                                    NULL, -- in_ts_form_no,
                                                                    v_hos_paket_uyesi, -- in_beklenen_kapanma_tarihi,
                                                                    igiren_kullanici,
                                                                    'O', -- durum
                                                                    'HOS PAKET ÜYESI - EKIPMAN (KART) ÇIKARMADAN',
                                                                    'OIP',
                                                                    v_taa_uyari,
                                                                    v_sonuc
                                                                   );

                     IF v_sonuc <> '0' THEN
                        odurum      := v_sonuc;
                        oproc_name  := 'uyelik_iptali_pack.uyelik_iptal_insert_update';
                        oerror_type := 1;
                        oerror_code := 'ERR347';
                        oerror_text := odurum;
                        RETURN;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      work_order_pack.work_order_insert (iuye_no,
                                         iservice_address_id,
                                         v_wiz_employee_code,
                                         ibayi_kodu,
                                         v_islem_tipi,
                                         v_work_order_number,
                                         v_sonuc,
                                         v_disconnect_reason_code
                                        );

      IF v_sonuc <> '0' THEN
         odurum      := 'WORK ORDER INSERT:' || v_sonuc;
         oproc_name  := 'WORK ORDER INSERT';
         oerror_type := 1;
         oerror_code := 'ERR347';
         oerror_text := odurum;
         RETURN;
      END IF;

      --uyenIn  o work order IÇIn hIc aÇik satiri yoksa o wo yu kapa --03/04/2002 mutlu+esen
      OPEN acik_wo_var_mi (v_work_order_number);

      FETCH acik_wo_var_mi INTO acik_wo_var_mi_rec;

      IF acik_wo_var_mi%FOUND THEN
         work_order_pack.close_wo (v_work_order_number, NULL, v_outlet_location, NULL, NULL, NULL, SYSDATE, igiren_kullanici, v_uyari_mesaji, v_sonuc);

         IF v_sonuc <> '0' THEN
            odurum      := v_sonuc;
            oproc_name  := 'CLOSE_WO';
            oerror_type := 1;
            oerror_code := 'ERR347';
            oerror_text := odurum;
            RETURN;
         END IF;
      END IF;

      CLOSE acik_wo_var_mi;

      ---------------------------------------------
      --oppv kontrol ve ISlemlerI
      ---------------------------------------------
      /* 31032010 falamur  Sadece kart için bu sinyaller çıkacaktır. */
      IF v_type = 'SC' THEN
         film_istek_pack.film_istek_diger_islemler (iuye_no, ioutlet_location, iserial_number, 1, igiren_kullanici, v_sonuc);
      END IF;

      IF v_sonuc <> '0' THEN
         odurum      := v_sonuc;
         oproc_name  := 'FILM_ISTEK_DIGER_ISLEMLER';
         oerror_type := 1;
         oerror_code := 'ERR347';
         oerror_text := odurum;
         RETURN;
      END IF;

      ekipman_pack.wiz_equip_to_location_insert (iserial_number,
                                                 v_depoya,
                                                 v_work_order_number,
                                                 ibayi_kodu,
                                                 1,
                                                 v_old_lokasyon,
                                                 v_wiz_operator_id,
                                                 v_trx_tarih,
                                                 v_sonuc
                                                );

      IF v_sonuc <> '0' THEN
         odurum      := v_sonuc;
         oproc_name  := 'WIZ EQUIP TO LOCATION INSERT';
         oerror_type := 1;
         oerror_code := 'ERR347';
         oerror_text := odurum;
         RETURN;
      END IF;

      ekipman_pack.ekipman_log_insert (iserial_number,
                                       iuye_no,
                                       ioutlet_location,
                                       NULL,
                                       ibayi_kodu,
                                       v_depoya,
                                       v_old_lokasyon,
                                       ireason_code,
                                       its_form_no,
                                       igiren_kullanici,
                                       v_work_order_number,
                                       v_trx_tarih,
                                       in_otorizasyon_no,
                                       in_ts_sifre_id,
                                       in_aciklama,
                                       v_sonuc
                                      );

      IF v_sonuc <> '0' THEN
         odurum      := v_sonuc;
         oproc_name  := 'EKIPMAN LOG INSERT';
         oerror_type := 1;
         oerror_code := 'ERR347';
         oerror_text := odurum;
         RETURN;
      END IF;

      IF v_type = 'SC' THEN
         work_order_pack.equip_changes (iserial_number,
                                        v_channel_map_1,
                                        v_channel_map_2,
                                        v_channel_map_3,
                                        v_channel_map_4,
                                        v_ppv_purchase_current_limit,
                                        NULL,
                                        NULL,
                                        SYSDATE,
                                        igiren_kullanici,
                                        v_sonuc
                                       );

         IF v_sonuc <> '0' THEN
            odurum      := v_sonuc;
            oproc_name  := 'EQUIP CHANGES';
            oerror_type := 1;
            oerror_code := 'ERR347';
            oerror_text := odurum;
            RETURN;
         END IF;
      END IF;

      odurum                   := v_sonuc;
      ois_emri                 := v_work_order_number;
   EXCEPTION
      WHEN OTHERS THEN
         odurum      := SQLERRM;
         oproc_name  := 'ekipman_cikar';
         oerror_type := 1;
         oerror_code := 'ERR346';
         oerror_text := odurum;
   END ekipman_cikar;

   PROCEDURE ekipman_log_insert (in_serial_number     IN     lg_ekipman.serial_number%TYPE,
                                 in_account_number    IN     lg_ekipman.account_number%TYPE,
                                 in_outlet            IN     lg_ekipman.outlet_location%TYPE,
                                 in_sozlesme_no       IN     lg_ekipman.sozlesme_no%TYPE,
                                 in_sales_agent_code  IN     lg_ekipman.sales_agent_code%TYPE,
                                 in_depoya            IN     lg_ekipman.depoya%TYPE,
                                 in_depodan           IN     lg_ekipman.depodan%TYPE,
                                 in_reason_code       IN     lg_ekipman.reason_code%TYPE,
                                 in_ts_form_no        IN     lg_ekipman.ts_form_no%TYPE,
                                 in_giren_kullanici   IN     lg_ekipman.giren_kullanici%TYPE,
                                 in_work_order_number IN     lg_ekipman.work_order_number%TYPE,
                                 in_trx_tarih         IN     wiz_equip_trx.trx_date%TYPE,
                                 in_otorizasyon_no    IN     lg_ekipman.otorizasyon_no%TYPE,
                                 in_ts_sifre_id       IN     lg_ekipman.lg_teknik_servis_sifre_id%TYPE,
                                 in_aciklama          IN     lg_ekipman.aciklama%TYPE,
                                 v_durum                 OUT VARCHAR2,
                                 in_irsaliye_no       IN     lg_ekipman.irsaliye_no%TYPE DEFAULT NULL
                                ) IS
      v_id                lg_ekipman.id%TYPE;
      v_kullanici_kodu    lg_ekipman.giren_kullanici%TYPE;
      v_serial_number     lg_ekipman.serial_number%TYPE;
      v_account_number    lg_ekipman.account_number%TYPE;
      v_outlet            lg_ekipman.outlet_location%TYPE;
      v_sozlesme_no       lg_ekipman.sozlesme_no%TYPE;
      v_sales_agent_code  lg_ekipman.sales_agent_code%TYPE;
      v_depoya            lg_ekipman.depoya%TYPE;
      v_depodan           lg_ekipman.depodan%TYPE;
      v_reason_code       lg_ekipman.reason_code%TYPE;
      v_ts_form_no        lg_ekipman.ts_form_no%TYPE;
      v_work_order_number lg_ekipman.work_order_number%TYPE;
      v_trx_tarih         wiz_equip_trx.trx_date%TYPE;
      v_deger             lg_abone_islem_takip.deger%TYPE;
      v_dbs_sabit         lg_ekipman.reason_code%TYPE;
      v_otorizasyon_no    lg_ekipman.otorizasyon_no%TYPE;
      v_ts_sifre_id       lg_ekipman.lg_teknik_servis_sifre_id%TYPE;
   BEGIN
      v_durum             := '0';

      IF in_serial_number IS NULL THEN
         v_durum := '-1';
      END IF;

      IF in_reason_code IS NULL THEN
         v_durum := '-1';
      END IF;

      v_dbs_sabit         := dbs_sabit ('DEPODAN SEVKIYAT');

      IF LTRIM (RTRIM (in_reason_code)) <> LTRIM (RTRIM (v_dbs_sabit)) THEN
         IF in_depoya IS NULL OR in_depodan IS NULL THEN
            IF in_outlet IS NULL THEN
               v_durum := '-1';
            END IF;
         END IF;
      END IF;

      IF in_trx_tarih IS NULL THEN
         v_durum := '-1';
      END IF;

      v_kullanici_kodu    := NVL (LTRIM (in_giren_kullanici), 'SYSTEM');
      v_serial_number     := TRIM (in_serial_number);
      v_account_number    := TRIM (in_account_number);
      v_outlet            := TRIM (in_outlet);
      v_sozlesme_no       := TRIM (in_sozlesme_no);
      v_sales_agent_code  := TRIM (in_sales_agent_code);
      v_depoya            := TRIM (in_depoya);
      v_depodan           := TRIM (in_depodan);
      v_reason_code       := TRIM (in_reason_code);
      v_ts_form_no        := TRIM (in_ts_form_no);
      v_work_order_number := TRIM (in_work_order_number);
      v_trx_tarih         := in_trx_tarih;
      v_otorizasyon_no    := TRIM (in_otorizasyon_no);
      v_ts_sifre_id       := TRIM (in_ts_sifre_id);

      IF v_durum <> '-1' THEN
         SELECT lg_ekipman_id_seq.NEXTVAL INTO v_id FROM DUAL;

         INSERT
           INTO lg_ekipman (id,
                            serial_number,
                            islem_tarihi,
                            account_number,
                            sales_agent_code,
                            sozlesme_no,
                            depoya,
                            depodan,
                            outlet_location,
                            reason_code,
                            ts_form_no,
                            giren_kullanici,
                            work_order_number,
                            otorizasyon_no,
                            lg_teknik_servis_sifre_id,
                            aciklama,
                            irsaliye_no
                           )
            VALUES (
                      v_id,
                      v_serial_number,
                      v_trx_tarih,
                      v_account_number,
                      v_sales_agent_code,
                      v_sozlesme_no,
                      TRIM (v_depoya),
                      TRIM (v_depodan),
                      v_outlet,
                      v_reason_code,
                      v_ts_form_no,
                      v_kullanici_kodu,
                      v_work_order_number,
                      v_otorizasyon_no,
                      v_ts_sifre_id,
                      in_aciklama,
                      in_irsaliye_no);

         v_deger := v_outlet || ',' || v_reason_code || ',' || v_otorizasyon_no;

         IF RTRIM (LTRIM (v_depoya)) IS NOT NULL AND RTRIM (LTRIM (v_depodan)) IS NOT NULL THEN
            v_deger := v_depoya || ',' || v_depodan || ',' || v_reason_code;
            log_pack.lg_abone_islem_takip_insert (v_account_number, v_deger, v_serial_number, '48', v_kullanici_kodu, v_durum);
         ELSIF RTRIM (LTRIM (v_depoya)) IS NOT NULL AND RTRIM (LTRIM (v_account_number)) IS NOT NULL THEN
            log_pack.lg_abone_islem_takip_insert (v_account_number, v_deger, v_serial_number, '18', v_kullanici_kodu, v_durum);
         ELSIF RTRIM (LTRIM (v_depodan)) IS NOT NULL AND RTRIM (LTRIM (v_account_number)) IS NOT NULL THEN
            log_pack.lg_abone_islem_takip_insert (v_account_number, v_deger, v_serial_number, '17', v_kullanici_kodu, v_durum);
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         v_durum := SQLERRM;
         RETURN;
   END ekipman_log_insert;

   PROCEDURE ekipman_degistir (p_serial_number_dusur IN     wiz_equip.serial_number%TYPE,
                               p_serial_number_ekle  IN     wiz_equip.serial_number%TYPE,
                               p_sales_agent_code    IN     wiz_equip.technician%TYPE,
                               p_kullanici           IN     co_kullanici.kod%TYPE,
                               p_error_type             OUT NUMBER,
                               p_error_code             OUT VARCHAR2,
                               p_error_text             OUT VARCHAR2
                              ) IS
      v_account_number     wiz_equip.account_number%TYPE;
      v_outlet_location    wiz_equip.outlet_location%TYPE;
      v_service_address_id wiz_equip.service_address_id%TYPE;
      v_reason_code        lg_ekipman.reason_code%TYPE;
      v_aciklama           lg_ekipman.aciklama%TYPE;
      v_depoya             wiz_equip.equip_location_code%TYPE;
      v_bayi_kodu          wiz_equip.technician%TYPE;
      v_durum              VARCHAR2 (512);
      v_proc_name          VARCHAR2 (124);
      v_is_emri_no         NUMBER (10);
      v_count              NUMBER (3);
      v_memo_kodu          co_memo_bilgi.memo_kodu%TYPE;
      v_taa_uyari          VARCHAR2 (512);
   BEGIN
      v_durum       := '0';
      v_memo_kodu   := 3486; --'ÜYENIN KARTI YENI KARTLA DEGISECEK'
      p_error_type  := 0;
      p_error_code  := 'VLD348';
      p_error_text  := NULL;

      BEGIN
         SELECT account_number, outlet_location, service_address_id
           INTO v_account_number, v_outlet_location, v_service_address_id
           FROM wiz_equip
          WHERE serial_number = p_serial_number_dusur;
      EXCEPTION
         WHEN OTHERS THEN
            p_error_type := 1;
            p_error_code := 'ERR350';
            p_error_text := 'DÜSÜRÜLECEK EKIPMAN BULUNAMADI';
            RETURN;
      END;

      v_reason_code := 'SMS';
      v_aciklama    := 'Düsürülen Ekipman Seri No :' || p_serial_number_dusur || ' Eklenen Ekipman Seri No :' || p_serial_number_ekle;

      /*
      SMS ile yapilan kart degisim isleminde üyeye verilen yeni kart hangi depoda ise eski kart da o depoya,
      islemi yapan YTS yeni kartin deposunun YTS'si olsun. Eger bu YTS IN bir YTS ise hata mesaji versin.
      */
      --YENI EKIPMAN BASKA BIR ABONE ÜZERINDE OLAMAZ
      SELECT COUNT (*)
        INTO v_count
        FROM wiz_equip
       WHERE serial_number = p_serial_number_ekle AND account_number = 0;

      IF v_count = 0 THEN
         p_error_type := 1;
         p_error_code := 'ERR360';
         p_error_text := 'EKLENECEK EKIPMAN BULUNAMADI VEYA BASKA BIR ABONE ÜZERINDE';
         RETURN;
      END IF;

      -- Yeni Ekipmanin Deposunu ve Teknik servisini bul.
      IF TRIM (p_sales_agent_code) IS NULL THEN
         BEGIN
            SELECT e.equip_location_code, l.employee_code
              INTO v_depoya, v_bayi_kodu
              FROM wiz_equip e,
                   wiz_equip_location_codes l
             WHERE e.equip_location_code = l.equip_location_code AND serial_number = p_serial_number_ekle AND assignable = 'Y';
         EXCEPTION
            WHEN OTHERS THEN
               p_error_type := 1;
               p_error_code := 'ERR347';
               p_error_text := 'EKIPMANIN DEPO BILGISI BULUNAMADI';
               RETURN;
         END;
      ELSE
         v_bayi_kodu := p_sales_agent_code;

         BEGIN
            SELECT equip_location_code
              INTO v_depoya
              FROM wiz_equip_location_codes
             WHERE assignable = 'Y' AND employee_code = v_bayi_kodu;
         EXCEPTION
            WHEN OTHERS THEN
               p_error_type := 1;
               p_error_code := 'ERR347';
               p_error_text := 'EKIPMANIN DEPO BILGISI BULUNAMADI';
               RETURN;
         END;
      END IF;

      -- Yeni ekipmanin teknik servisinin aktif olup olmadigini bul.
      SELECT COUNT (*)
        INTO v_count
        FROM vv_bayi_teknik_servis
       WHERE sales_agent_code = v_bayi_kodu;

      IF v_count = 0 THEN
         p_error_type := 1;
         p_error_code := 'ERR365';
         p_error_text := 'BAYI KODU BULUNAMADI';
         RETURN;
      END IF;

      ekipman_pack.ekipman_cikar (v_account_number,
                                  p_serial_number_dusur,
                                  v_outlet_location,
                                  v_bayi_kodu,
                                  NULL,
                                  v_reason_code,
                                  v_depoya,
                                  v_service_address_id,
                                  p_kullanici,
                                  NULL,
                                  NULL,
                                  v_aciklama,
                                  v_durum,
                                  v_taa_uyari,
                                  v_proc_name,
                                  v_is_emri_no,
                                  p_error_type,
                                  p_error_code,
                                  p_error_text
                                 );

      IF v_durum <> '0' THEN
         RETURN;
      END IF;

      SELECT COUNT (*)
        INTO v_count
        FROM (SELECT kampanya_ozellik AS kampanya_ozellik
                FROM vv_kampanya_ekipman
               WHERE kampanya_kodu IN (SELECT campaign_code
                                         FROM yk_dp_kontrat
                                        WHERE uye_no = v_account_number AND outlet_location = v_outlet_location)) a,
             (SELECT ekipman_tip_bul (p_serial_number_dusur) AS kampanya_ozellik FROM DUAL) b
       WHERE a.kampanya_ozellik = b.kampanya_ozellik;

      IF v_count > 0 THEN
         IF yetki_pack.yetkisi_varmi (p_kullanici, 'YETKI_CIKAR_EKIPMAN_KAMPANYA_ZORUNLU') = 0 THEN
            p_error_type := 1;
            p_error_code := 'ERR347';
            p_error_text := 'YETKI_CIKAR_EKIPMAN_KAMPANYA_ZORUNLU YETKISI YOK';
            RETURN;
         END IF;
      END IF;

      ekipman_pack.ekipman_ekle (v_account_number,
                                 p_serial_number_ekle,
                                 v_outlet_location,
                                 v_bayi_kodu,
                                 NULL,
                                 v_reason_code,
                                 NULL, --idepoya
                                 v_service_address_id,
                                 'N',
                                 'N',
                                 p_kullanici,
                                 NULL,
                                 NULL,
                                 NULL,
                                 v_aciklama,
                                 v_durum,
                                 v_proc_name,
                                 v_is_emri_no,
                                 p_error_type,
                                 p_error_code,
                                 p_error_text
                                );

      IF v_durum <> '0' THEN
         RETURN;
      END IF;

      bt_uye_ts_pack.bt_uye_ts_guncel_feed (v_account_number,
                                            v_outlet_location,
                                            v_bayi_kodu,
                                            3, --IN_YTS_ISLEM_TIPI
                                            'C', --IN_STATUS
                                            NULL, --IN_MEMO_KOD,
                                            NULL, --IN_SEBEP_KOD,
                                            4, --IN_EKRAN_KOD
                                            p_kullanici,
                                            'EKIPMAN DEGISIM_SMS',
                                            v_durum
                                           );

      IF v_durum <> '0' THEN
         p_error_type := 1;
         p_error_code := 'ERR396';
         p_error_text := 'GÜNCEL TS ISLEMLERI YAPILAMADI';
         RETURN;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_error_type := 1;
         p_error_code := 'ERR346';
         p_error_text := 'ekipman_pack.ekipman_degistir : ' || SQLERRM;
         RETURN;
   END ekipman_degistir;

   PROCEDURE ekipman_degistir_dbs (p_account_number     IN     wiz_equip.account_number%TYPE,
                                   p_serial_number_ekle IN     wiz_equip.serial_number%TYPE,
                                   p_aciklama           IN     VARCHAR2,
                                   p_kullanici          IN     co_kullanici.kod%TYPE,
                                   p_durum                 OUT VARCHAR2
                                  ) IS
      v_account_number      wiz_equip.account_number%TYPE;
      v_outlet_location     wiz_equip.outlet_location%TYPE;
      v_converter_type      wiz_equip.converter_type%TYPE;
      v_serial_number_dusur wiz_equip.serial_number%TYPE;
      v_service_address_id  wiz_equip.service_address_id%TYPE;
      v_eq_deg_id           eq_ekipman_degisim.id%TYPE;
      v_reason_code         lg_ekipman.reason_code%TYPE;
      v_aciklama            lg_ekipman.aciklama%TYPE;
      v_depoya              wiz_equip.equip_location_code%TYPE;
      v_bayi_kodu           wiz_equip.technician%TYPE;
      v_proc_name           VARCHAR2 (124);
      v_is_emri_no          NUMBER (10);
      v_count               NUMBER (3);
      p_error_type          NUMBER (1);
      p_error_code          VARCHAR2 (10);
      p_error_text          VARCHAR2 (512);
      v_taa_uyari           VARCHAR2 (512);
   BEGIN
      p_durum       := '0';

      SELECT COUNT (*)
        INTO v_count
        FROM eq_ekipman_degisim
       WHERE account_number = p_account_number AND ekipman_degisti = 'H';

      IF v_count = 0 THEN
         p_durum := 'BU ÜYENIN EKIPMANI DEGISTIRILEMEZ';
         RETURN;
      END IF;

      BEGIN
         SELECT account_number, outlet_location, id
           INTO v_account_number, v_outlet_location, v_eq_deg_id
           FROM eq_ekipman_degisim
          WHERE account_number = p_account_number AND serial_number = p_serial_number_ekle AND ekipman_degisti = 'H';
      EXCEPTION
         WHEN OTHERS THEN
            p_durum := 'EKLENECEK EKIPMAN BULUNAMADI';
            RETURN;
      END;

      BEGIN
         SELECT converter_type
           INTO v_converter_type
           FROM wiz_equip
          WHERE serial_number = p_serial_number_ekle AND account_number = 0;
      EXCEPTION
         WHEN OTHERS THEN
            p_durum := 'EKLENECEK EKIPMAN BULUNAMADI VEYA BASKA BIR ABONE ÜZERINDE';
            RETURN;
      END;

      IF ekipman_durumu_pack.dummy_mi (p_serial_number_ekle) = 1 THEN
         p_durum := 'DUMMY EKIPMAN! EKLENEMEZ';
         RETURN;
      END IF;

      BEGIN
         SELECT serial_number
           INTO v_serial_number_dusur
           FROM wiz_equip
          WHERE account_number = v_account_number AND outlet_location = v_outlet_location AND converter_type = v_converter_type;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF yetki_pack.yetkisi_varmi (p_kullanici, 'ISLEM_EKIP_DEG_DUSEN_EKIPMAN_YOK') = 0 THEN
               p_durum := 'DÜSÜRÜLECEK EKIPMAN BULUNAMADI !';
               RETURN;
            END IF;
         WHEN OTHERS THEN
            p_durum := 'DÜSÜRÜLECEK EKIPMAN HATALI !';
            RETURN;
      END;

      IF ekipman_durumu_pack.dummy_mi (v_serial_number_dusur) = 1 THEN
         p_durum := 'DUMMY EKIPMAN! DÜSÜRÜLEMEZ';
         RETURN;
      END IF;

      BEGIN
         SELECT service_address_id
           INTO v_service_address_id
           FROM wiz_customer_hp_life
          WHERE account_number = v_account_number;
      EXCEPTION
         WHEN OTHERS THEN
            p_durum := 'BINA_ID BULUNAMADI';
            RETURN;
      END;

      IF v_serial_number_dusur IS NOT NULL THEN
         SELECT COUNT (*)
           INTO v_count
           FROM (SELECT kampanya_ozellik AS kampanya_ozellik
                   FROM vv_kampanya_ekipman
                  WHERE kampanya_kodu IN (SELECT campaign_code
                                            FROM yk_dp_kontrat
                                           WHERE uye_no = v_account_number AND outlet_location = v_outlet_location)) a,
                (SELECT ekipman_tip_bul (v_serial_number_dusur) AS kampanya_ozellik FROM DUAL) b
          WHERE a.kampanya_ozellik = b.kampanya_ozellik;

         IF v_count > 0 THEN
            IF yetki_pack.yetkisi_varmi (p_kullanici, 'YETKI_CIKAR_EKIPMAN_KAMPANYA_ZORUNLU') = 0 THEN
               p_durum := 'YETKI_CIKAR_EKIPMAN_KAMPANYA_ZORUNLU YETKISI YOK';
               RETURN;
            END IF;
         END IF;
      END IF;

      v_reason_code := 'KUR';
      v_aciklama    := 'Düsürülen Ekipman Seri No :' || v_serial_number_dusur || ' Eklenen Ekipman Seri No :' || p_serial_number_ekle;
      v_depoya      := 'SWP';
      v_bayi_kodu   := 'KURYENET';

      IF v_serial_number_dusur IS NOT NULL THEN
         ekipman_pack.ekipman_cikar (v_account_number,
                                     v_serial_number_dusur,
                                     v_outlet_location,
                                     v_bayi_kodu,
                                     NULL,
                                     v_reason_code,
                                     v_depoya,
                                     v_service_address_id,
                                     p_kullanici,
                                     NULL,
                                     NULL,
                                     v_aciklama,
                                     p_durum,
                                     v_taa_uyari,
                                     v_proc_name,
                                     v_is_emri_no,
                                     p_error_type,
                                     p_error_code,
                                     p_error_text
                                    );

         IF p_durum <> '0' THEN
            RETURN;
         END IF;
      END IF;

      ekipman_pack.ekipman_ekle (v_account_number,
                                 p_serial_number_ekle,
                                 v_outlet_location,
                                 v_bayi_kodu,
                                 NULL,
                                 v_reason_code,
                                 NULL, --idepoya
                                 v_service_address_id,
                                 'N',
                                 'N',
                                 p_kullanici,
                                 NULL,
                                 NULL,
                                 NULL,
                                 v_aciklama,
                                 p_durum,
                                 v_proc_name,
                                 v_is_emri_no,
                                 p_error_type,
                                 p_error_code,
                                 p_error_text
                                );

      IF p_durum <> '0' THEN
         RETURN;
      END IF;

      bt_uye_ts_pack.bt_uye_ts_guncel_feed (v_account_number,
                                            v_outlet_location,
                                            v_bayi_kodu,
                                            3, --IN_YTS_ISLEM_TIPI
                                            'C', --IN_STATUS
                                            NULL, --IN_MEMO_KOD,
                                            v_reason_code,
                                            4, --IN_EKRAN_KOD
                                            p_kullanici,
                                            'EKIPMAN DEGISIM_DBS',
                                            p_durum
                                           );

      IF p_durum <> '0' THEN
         p_durum := 'GÜNCEL TS ISLEMLERI YAPILAMADI';
         RETURN;
      END IF;

      UPDATE eq_ekipman_degisim
         SET ekipman_degisti = 'E', aciklama = SUBSTR (aciklama || '-' || p_aciklama, 1, 256), degistiren_kullanici = p_kullanici, degistirme_tarihi = SYSDATE
       WHERE id = v_eq_deg_id;
   EXCEPTION
      WHEN OTHERS THEN
         p_durum := 'ekipman_pack.ekipman_degistir_dbs : ' || SQLERRM;
   END ekipman_degistir_dbs;

   /*
     description: encode data from eq_ekipman_tip_matrix
 */
   FUNCTION get_ekipman_tip_matrix (isource_type     IN NUMBER,
                                    --0:dont care,1 : wiz_equip,2: eq_ekipman(non-encode) ,3: eq_ekipman (encoded)
                                    iconverter_type  IN eq_ekipman_tip_matrix.converter_type%TYPE,
                                    --null : dont care
                                    iconverter_model IN eq_ekipman_tip_matrix.converter_model%TYPE,
                                    --null : dont care
                                    imanufacturer    IN eq_ekipman_tip_matrix.manufacturer%TYPE,
                                    --null : dont care
                                    igiren_kullanici IN co_kullanici.kod%TYPE,
                                    ioutput_type     IN VARCHAR2 DEFAULT 'converter_type' -- converter_type,converter_model,manufacturer
                                   )
      RETURN dbs_collection -- key, value pair.
                           IS
      v_ret dbs_collection;
   BEGIN
      SELECT CAST (
                MULTISET (
                   SELECT NVL (key_column, TO_CHAR (10000 + ROWNUM)) key_column, value_column
                     FROM (SELECT DISTINCT
                                  DECODE (
                                     isource_type,
                                     3, DECODE (ioutput_type,
                                                'converter_type', converter_type,
                                                'converter_model', converter_model,
                                                'manufacturer', manufacturer,
                                                '0'
                                               ))
                                     key_column,
                                  DECODE (
                                     isource_type,
                                     3, (SELECT aciklama
                                           FROM pr_genel_tip_detay
                                          WHERE TO_CHAR (id) =
                                                   DECODE (ioutput_type,
                                                           'converter_type', converter_type,
                                                           'converter_model', converter_model,
                                                           'manufacturer', manufacturer,
                                                           converter_type
                                                          )),
                                     DECODE (ioutput_type,
                                             'converter_type', converter_type,
                                             'converter_model', converter_model,
                                             'manufacturer', manufacturer,
                                             converter_type
                                            ))
                                     value_column
                             FROM eq_ekipman_tip_matrix
                            WHERE     eq_ekipman_tip_matrix.listeden_gizle = 'H'
                                  AND (   isource_type = 0
                                       OR (isource_type = 1 AND source_type = 956)
                                       OR ( (isource_type = 2 OR isource_type = 3) AND source_type = 957))
                                  AND (   iconverter_type IS NULL
                                       OR converter_type IN (SELECT TO_CHAR (id)
                                                               FROM pr_genel_tip_detay
                                                              WHERE aciklama = iconverter_type AND isource_type = 3
                                                             UNION ALL
                                                             SELECT iconverter_type FROM DUAL))
                                  AND (   iconverter_model IS NULL
                                       OR converter_model IN (SELECT TO_CHAR (id)
                                                                FROM pr_genel_tip_detay
                                                               WHERE aciklama = iconverter_model AND isource_type = 3
                                                              UNION ALL
                                                              SELECT iconverter_model FROM DUAL))
                                  AND (   imanufacturer IS NULL
                                       OR manufacturer IN (SELECT TO_CHAR (id)
                                                             FROM pr_genel_tip_detay
                                                            WHERE aciklama = imanufacturer AND isource_type = 3
                                                           UNION ALL
                                                           SELECT imanufacturer FROM DUAL)))) AS dbs_collection)
        INTO v_ret
        FROM DUAL;

      RETURN v_ret;
   END;

   PROCEDURE check_ekipman_serial (iserial_number   IN     VARCHAR2,
                                   isource_type     IN     NUMBER,
                                   --0:dont care,1 : wiz_equip,2: eq_ekipman(non-encode)
                                   iconverter_type  IN     eq_ekipman_tip_matrix.converter_type%TYPE,
                                   --null : dont care
                                   iconverter_model IN     eq_ekipman_tip_matrix.converter_model%TYPE,
                                   --null : dont care
                                   imanufacturer    IN     eq_ekipman_tip_matrix.manufacturer%TYPE,
                                   --null : dont care
                                   igiren_kullanici IN     co_kullanici.kod%TYPE,
                                   osonuc              OUT NUMBER,
                                   -- 0: not found,1: found wiz_equip , 2 found eq_ekipman, 3 found both
                                   durum               OUT VARCHAR2
                                  ) IS
      v_bulundu NUMBER (1);
   BEGIN
      durum     := '0';
      osonuc    := 0;
      v_bulundu := 0;

      IF isource_type = 0 OR isource_type = 1 THEN
         SELECT COUNT (1)
           INTO v_bulundu
           FROM wiz_equip
          WHERE     account_number = 0
                AND serial_number = iserial_number
                AND (iconverter_type IS NULL OR TRIM (converter_type) = iconverter_type)
                AND (iconverter_model IS NULL OR TRIM (converter_model) = iconverter_model)
                AND (imanufacturer IS NULL OR TRIM (manufacturer) = imanufacturer);

         IF v_bulundu = 1 THEN
            osonuc := 1;
         END IF;
      END IF;

      IF isource_type = 0 OR isource_type = 2 THEN
         SELECT COUNT (1)
           INTO v_bulundu
           FROM eq_ekipman
          WHERE     (account_number IS NULL)
                AND serial_number = iserial_number
                AND (iconverter_type IS NULL OR ekipman_tipi = iconverter_type)
                AND (iconverter_model IS NULL OR ekipman_modul_tipi = iconverter_model);

         IF v_bulundu = 1 THEN
            IF osonuc = 0 THEN
               osonuc := 2;
            END IF;

            IF osonuc = 1 THEN
               osonuc := 3;
            END IF;
         END IF;
      END IF;

      IF osonuc = 0 THEN
         SELECT COUNT (1)
           INTO v_bulundu
           FROM wiz_equip
          WHERE account_number = 0 AND serial_number = iserial_number;

         IF v_bulundu = 1 THEN
            RETURN;
         END IF;

         SELECT COUNT (1)
           INTO v_bulundu
           FROM eq_ekipman
          WHERE (account_number IS NULL) AND serial_number = iserial_number;

         IF v_bulundu = 1 THEN
            RETURN;
         END IF;

         osonuc := -1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         durum := 'ekipman_pack.check_ekipman_serial : ' || SQLERRM;
   END check_ekipman_serial;

   FUNCTION get_ekipman_serial (in_account_number IN NUMBER, in_outlet VARCHAR2, in_ekipman_tipi IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_equip_serial eq_ekipman.serial_number%TYPE;
   BEGIN
      IF UPPER (TRIM (in_ekipman_tipi)) IN ('KART', 'KUTU') THEN
         SELECT serial_number
           INTO v_equip_serial
           FROM wiz_equip
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet
                AND converter_type = CASE in_ekipman_tipi WHEN 'KART' THEN 'SC' WHEN 'KUTU' THEN 'ST' END;
      ELSIF TRIM (in_ekipman_tipi) IN ('MODÜL', 'KEN', 'MODEM', 'HARDDİSK') THEN
         SELECT serial_number
           INTO v_equip_serial
           FROM eq_ekipman
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet
                AND ekipman_tipi = CASE in_ekipman_tipi WHEN 'MODÜL' THEN '248' WHEN 'KEN' THEN '300' WHEN 'MODEM' THEN '301' WHEN 'HARDDİSK' THEN '302' END;
      END IF;

      RETURN v_equip_serial;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
   END get_ekipman_serial;

   PROCEDURE ekipman_uyumsuz_servis_dusur (in_account_number  IN     NUMBER,
                                           in_outlet_location IN     VARCHAR2,
                                           in_kullanici       IN     VARCHAR2,
                                           oerror_type           OUT NUMBER,
                                           oerror_code           OUT VARCHAR2,
                                           oerror_text           OUT VARCHAR2
                                          ) IS
      v_ittp_token   VARCHAR2 (1000);
      v_servis_dusur CHAR (1);
      odurum         VARCHAR2 (1000);
   BEGIN
      IF in_account_number IS NULL OR TRIM (in_outlet_location) IS NULL THEN
         oerror_type := -1;
         oerror_code := -1;
         oerror_text := 'Account ya da outlet bilgisi boş olamaz';
      END IF;

      FOR rec_ IN (SELECT 'SVC' AS itemtype, service_code, servis_frekansi, campaign_code
                     FROM dt_dbs_int_dba.vv_uye_ittp_servisler
                    WHERE account_number = in_account_number AND outlet_location = in_outlet_location /*UNION
                                                                                                      SELECT 'WO' AS itemtype,
                                                                                                             service_code,
                                                                                                             servis_frekansi,
                                                                                                             campaign_code
                                                                                                        FROM DT_DBS_INT_DBA.VV_ITTP_CUSTOMER_ORDER
                                                                                                       WHERE     job_code = 'ADD'
                                                                                                             AND work_order_statu IN ('ACIK', 'BEKLEMEDE')
                                                                                                             AND work_line_statu = 'ACIK'
                                                                                                             AND dbs_account_number = in_account_number
                                                                                                             AND dbs_outlet_location = in_outlet_location*/
                                                                                                     ) LOOP
         oerror_type := 0;
         oerror_code := NULL;
         oerror_text := NULL;
         rama_servis.servisekipmanuyum (in_account_number,
                                        in_outlet_location,
                                        rec_.service_code,
                                        in_kullanici,
                                        oerror_text,
                                        odurum,
                                        oerror_type,
                                        oerror_code,
                                        v_servis_dusur,
                                        'SERVIS_EKLEME'
                                       );

         IF odurum <> '0' AND v_servis_dusur = 'E' THEN
            /*Önce ITTP'den çağrılacak fonksiyon için token alınıyor*/
            v_ittp_token      := dbs_dba.ittp_webservice_pack.systemauthenticate (dbs_sabit ('FRAMEWORK_DBS_USER'),
                                                                                  dbs_sabit ('FRAMEWORK_DBS_PASS'),
                                                                                  dbs_sabit ('FRAMEWORK_DBS_COMPANY_NAME'),
                                                                                  dbs_sabit ('FRAMEWORK_DBS_APP_NAME'),
                                                                                  dbs_sabit ('FRAMEWORK_DBS_CHANNEL_NAME'),
                                                                                  oerror_type,
                                                                                  oerror_code,
                                                                                  oerror_text
                                                                                 );

            IF oerror_type <> 0 THEN
               abone_batch_pack.insert_log ('EKIPMAN_UYUMSUZ_SERVIS_DUSUR_AUTH_EXCEPTION: ' || oerror_text);
               RETURN;
            ELSE
               /*token alındı, servis çağrılıyor*/
               dbs_dba.ittp_webservice_pack.dropproductandrelfutureorders (in_account_number,
                                                                           in_outlet_location,
                                                                           TRIM (rec_.service_code) || '_SRV',
                                                                           v_ittp_token,
                                                                           oerror_type,
                                                                           oerror_code,
                                                                           oerror_text
                                                                          );

               IF oerror_type <> 0 THEN
                  abone_batch_pack.insert_log (
                     'EKIPMAN_UYUMSUZ_SERVIS_DUSUR_EXCEPTION: ' || in_account_number || ' - ' || in_outlet_location || ' ' || oerror_text);
                  RETURN;
               END IF;
            END IF;
         ELSE
            /*servis ekipman uyumdan, success durumunda oerror_code yerine odurum = 0 geldiği için*/
            oerror_type := 0;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         oerror_type := -1;
         oerror_text := DBMS_UTILITY.format_error_backtrace ();
         abone_batch_pack.insert_log ('EKIPMAN_UYUMSUZ_SERVIS_DUSUR_SQL_EXCEPTION: ' || oerror_text);
         RETURN;
   END ekipman_uyumsuz_servis_dusur;
   /*Mustafa 07.11.2007 Bu procedure. turk kullanilmiyor
   PROCEDURE sadece_dum_dmy_servis_var_mi (
      iaccount_number   IN       wiz_equip.account_number%TYPE,
      ioutlet           IN       wiz_equip.outlet_location%TYPE,
      oservice_code     OUT      wiz_customer_hp_svc.service_code%TYPE,
      ocampaign_code    OUT      wiz_wo_line_items.campaign_code%TYPE,
      durum             OUT      VARCHAR2
   )
   IS
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_service_code      wiz_customer_hp_svc.service_code%TYPE;
      v_campaign_code     wiz_wo_line_items.campaign_code%TYPE;
      v_count             NUMBER;
      v_ser_durum         VARCHAR2 (3);

      CURSOR line_cur
      IS
         SELECT   *
             FROM (SELECT service_code
                     FROM wiz_wo_line_items, wiz_work_order
                    WHERE wiz_wo_line_items.work_order_number =
                                              wiz_work_order.work_order_number
                      AND wiz_work_order.account_number = v_account_number
                      AND wiz_wo_line_items.outlet_location =
                                                             v_outlet_location
                      AND wiz_work_order.wo_status IN ('O', 'P')
                      AND wiz_wo_line_items.wo_status = 'O'
                      AND NOT LTRIM (wiz_wo_line_items.service_code) IS NULL
                   UNION
                   SELECT service_code
                     FROM wiz_customer_hp_svc
                    WHERE account_number = v_account_number
                      AND outlet_location = v_outlet_location)
         ORDER BY service_code DESC;
   BEGIN
      durum := '0';
      v_account_number := iaccount_number;
      v_outlet_location := ioutlet;
      oservice_code := NULL;
      ocampaign_code := NULL;
      v_ser_durum := NULL;

      IF LTRIM (v_account_number) IS NULL
      THEN
         durum := '-1';
      END IF;

      IF LTRIM (v_outlet_location) IS NULL
      THEN
         durum := '-1';
      END IF;

      IF durum = '0'
      THEN
         SELECT COUNT (1)
           INTO v_count
           FROM ie_uyelik_dondurma
          WHERE account_number = v_account_number
            AND outlet_location = v_outlet_location
            AND durum = 'D';

         IF v_count > 0
         THEN
            durum := '0';
            oservice_code := 'ALE';
            ocampaign_code := 'KMP';
            RETURN;
         END IF;

         SELECT COUNT (1)
           INTO v_count
           FROM ie_uyelik_kapama
          WHERE account_number = v_account_number
            AND outlet_location = v_outlet_location
            AND durum = 'K';

         IF v_count > 0
         THEN
            durum := '0';
            oservice_code := 'ALE';
            ocampaign_code := 'KMP';
            RETURN;
         END IF;

         OPEN line_cur;

         LOOP
            FETCH line_cur
             INTO v_service_code;

            EXIT WHEN line_cur%NOTFOUND;
            oservice_code := v_service_code;
            v_ser_durum :=
               get_servis_durumu (v_account_number,
                                  v_outlet_location,
                                  v_service_code
                                 );

            IF v_ser_durum = 'ADD'
            THEN
               CLOSE line_cur;

               RETURN;
            END IF;
         END LOOP;

         IF LTRIM (v_ser_durum) IS NOT NULL
         THEN
            CLOSE line_cur;

            RETURN;
         END IF;

         RETURN;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         durum := SQLERRM;
         oservice_code := NULL;
         ocampaign_code := NULL;
   END sadece_dum_dmy_servis_var_mi;
*/
/*
Mustafa 24.11.2004 Bu proc. kullanilmiyor
FUNCTION ekipman_sahibi_unvan(iserial_number IN wiz_equip.serial_number%TYPE)
                     RETURN VARCHAR2
IS
v_uye_no EQ_EKIPMAN_SAHIBI_KIM.account_number%TYPE;
v_ts_no EQ_EKIPMAN_SAHIBI_KIM.sales_agent_code%TYPE;
v_ekipman_sahibi_tipi EQ_EKIPMAN_SAHIBI_KIM.ekipman_sahibi_tipi%TYPE;
v_unvan  VARCHAR2(150);

BEGIN
  BEGIN
   SELECT account_number,sales_agent_code,ekipman_sahibi_tipi
   INTO v_uye_no, v_ts_no, v_ekipman_sahibi_tipi
   FROM EQ_EKIPMAN_SAHIBI_KIM
   WHERE serial_number = iserial_number
   AND kayit_iptal = 'H';

  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END;

  IF trim(v_ekipman_sahibi_tipi) = 1 THEN
    BEGIN
     SELECT first_name ||' '|| last_name
     INTO v_unvan
     FROM wiz_customer_descrip
     WHERE account_number = trim(v_uye_no);

      RETURN 'ÜYE : '||v_uye_no ||' - '|| trim(v_unvan);

   EXCEPTION WHEN OTHERS THEN
       RETURN v_uye_no;
   END;

  ELSIF  trim(v_ekipman_sahibi_tipi) = 2 THEN
    BEGIN
     SELECT unvan
     INTO v_unvan
     FROM BT_BAYI_TEKNIK_SERVIS
     WHERE sales_agent_code = trim(v_ts_no);

      RETURN 'TS : '||v_ts_no ||' - '|| trim(v_unvan);

   EXCEPTION WHEN OTHERS THEN
       RETURN v_ts_no;
   END;
  ELSE
    RETURN NULL;
  END IF;
END;
*/
/*
Mustafa 24.11.2004 Bu proc. kullanilmiyor
PROCEDURE equip_location_to_location
(
 iserial_number IN wiz_equip.serial_number%TYPE,
 inew_location    IN wiz_equip.equip_location_code%TYPE,
 iold_location       IN wiz_equip.equip_location_code%TYPE,
 iwork_order_number     IN wiz_equip.work_order_number%TYPE,
 its_kodu       IN BT_BAYI_TEKNIK_SERVIS.sales_agent_code%TYPE,
 ireason_code            IN LG_EKIPMAN.reason_code%TYPE,
 its_form_no             IN LG_EKIPMAN.ts_form_no%TYPE,
 iotorizasyon_no         IN LG_EKIPMAN.otorizasyon_no%TYPE,
 its_sifre_id             IN LG_EKIPMAN.lg_teknik_servis_sifre_id%TYPE,
 iaciklama               IN LG_EKIPMAN.aciklama%TYPE,
 ikullanici_kodu IN CO_KULLANICI.kod%TYPE,
 odurum        OUT VARCHAR2,
 oproc_name    OUT VARCHAR2
)
IS
v_trx_tarih    DATE;
BEGIN
  ekipman_pack.lokas_to_lokas_yapilabilir(
                  iserial_number,0,inew_location,
                  its_kodu,ikullanici_kodu,odurum);

    IF odurum <> '0' THEN
      odurum := odurum;
      oproc_name := 'WIZ EQUIP TO ABONE INSERT';
      RETURN;
    END IF;

  ekipman_pack.wiz_equip_to_location_insert(
                  iserial_number,inew_location,iwork_order_number,
                  its_kodu,0,iold_location,ikullanici_kodu,v_trx_tarih,odurum);

    IF odurum <> '0' THEN
      odurum := odurum;
      oproc_name := 'WIZ EQUIP TO ABONE INSERT';
      RETURN;
    END IF;

   ekipman_pack.ekipman_log_insert(
                     iserial_number,0,NULL,
                  NULL,its_kodu,inew_location,iold_location,ireason_code,
                  its_form_no,ikullanici_kodu,iwork_order_number,v_trx_tarih,
                  iotorizasyon_no,its_sifre_id,iaciklama,
                  odurum);

    IF odurum <> '0' THEN
      odurum := odurum;
      oproc_name :='EKIPMAN LOG INSERT';
      RETURN;
    END IF;
END;
*/
END;
/
