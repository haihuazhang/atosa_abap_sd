CLASS zzcl_sd_020 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SD_020 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data TYPE STANDARD TABLE OF ZC_TSD013 WITH DEFAULT KEY.
    DATA lv_date TYPE abp_creation_date.
    DATA lv_time TYPE abp_creation_time.
    lt_original_data = CORRESPONDING #( it_original_data ).
    TRY.
        DATA(lv_timezone) = cl_abap_context_info=>get_user_time_zone( sy-uname ).
    CATCH CX_ABAP_CONTEXT_INFO_ERROR.
        EXIT.
    ENDTRY.
    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
        lv_date = <fs_original_data>-ScannedDate.
        lv_time = <fs_original_data>-ScannedTime.
        CONVERT TIME STAMP CONV timestamp( lv_date && lv_time )
            TIME ZONE lv_timezone
            INTO DATE <fs_original_data>-ScannedDate_TZ
                 TIME <fs_original_data>-ScannedTime_TZ.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
