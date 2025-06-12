CREATE OR REPLACE TRIGGER DBS_DBA.TRG_ITTP_CO_ULKE
   AFTER DELETE OR INSERT OR UPDATE
   ON dbs_dba.co_ulke
   REFERENCING NEW AS new OLD AS old
   FOR EACH ROW
DECLARE
   --PRAGMA AUTONOMOUS_TRANSACTION;
   -- v_row_country      co_ulke%ROWTYPE;
   v_result_type    VARCHAR2 (10);
   v_result_code    VARCHAR2 (50);
   v_result_message VARCHAR2 (256);
   v_onl_del        NUMBER;
   v_onl_id         VARCHAR2 (3);
BEGIN
   v_result_type := 0;

   /* Begin ITTP Integration - MGOKSU*/

   --
   IF DELETING THEN
      v_onl_del := 1;
      v_onl_id  := :old.id;
   ELSIF UPDATING THEN
      v_onl_del := 2;
      v_onl_id  := :old.id;
   ELSE
      v_onl_id  := :new.id;
      v_onl_del := NULL;
   END IF;

   billing_dbs_int.onl_address_ittp_pkg.country_int_sp (onl_id                   => v_onl_id,
                                                        onl_ad                   => :new.ad,
                                                        onl_giren_kullanici      => :new.giren_kullanici,
                                                        onl_giris_tarihi         => :new.giris_tarihi,
                                                        onl_degistiren_kullanici => :new.degistiren_kullanici,
                                                        onl_degistirme_tarihi    => :new.degistirme_tarihi,
                                                        onl_franchise_code_list  => :new.franchise_code_list,
                                                        onl_ing_ad               => :new.ing_ad,
                                                        onl_gca_descr            => :new.gca_descr,
                                                        onl_kita                 => :new.kita,
                                                        onl_ulus_kod             => :new.ulus_kod,
                                                        onl_text_kod             => :new.text_kod,
                                                        onl_del                  => v_onl_del,
                                                        o_result_type            => v_result_type,
                                                        o_result_code            => v_result_code,
                                                        o_result_message         => v_result_message
                                                       );

   IF v_result_type = 1 THEN
      raise_application_error (-20001, v_result_code || ':' || v_result_message);
   END IF;

   IF NOT DELETING THEN
      --tabiyet icin
      billing_dbs_int.onl_party_ittp_pkg.nationality_sp (onl_id                   => v_onl_id,
                                                         onl_ad                   => :new.ad,
                                                         onl_giren_kullanici      => :new.giren_kullanici,
                                                         onl_giris_tarihi         => :new.giris_tarihi,
                                                         onl_degistiren_kullanici => :new.degistiren_kullanici,
                                                         onl_degistirme_tarihi    => :new.degistirme_tarihi,
                                                         onl_franchise_code_list  => :new.franchise_code_list,
                                                         onl_ing_ad               => :new.ing_ad,
                                                         onl_gca_descr            => :new.gca_descr,
                                                         onl_kita                 => :new.kita,
                                                         onl_ulus_kod             => :new.ulus_kod,
                                                         onl_text_kod             => :new.text_kod,
                                                         o_result_type            => v_result_type,
                                                         o_result_code            => v_result_code,
                                                         o_result_message         => v_result_message
                                                        );

      IF v_result_type = 1 THEN
         raise_application_error (-20001, v_result_code || ':' || v_result_message);
      END IF;
   END IF;
--exception when others then
--rollback;

/*End ITTP Integration*/
END trg_ittp_co_ulke;
/
