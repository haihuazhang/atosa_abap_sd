CLASS zzcl_sd_002 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

*    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SD_002 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data TYPE STANDARD TABLE OF zc_ssd017 WITH DEFAULT KEY.
    lt_original_data = CORRESPONDING #( it_original_data ).
    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
*      <fs_original_data>-DaysToFlight =  <fs_original_data>-FlightDate - lv_today.
        read ENTITIES OF I_OutboundDeliveryTP
           ENTITY OutboundDeliveryText
           FIELDS ( LongText  ) WITH VALUE #( ( %tky-OutboundDelivery = <fs_original_data>-OutboundDelivery
                                                %tky-LongTextID = 'TX07'
                                                %tky-Language = 'E' ) )
        RESULT FINAL(LT_TEXT).
        if lines( LT_TEXT ) > 0.
            <fs_original_data>-LongText = LT_TEXT[ 1 ]-LongText.
        endif.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #(  lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
      CASE <fs_calc_element>.
        WHEN 'LONGTEXT'.
          INSERT `OUTBOUNDDELIVERY` INTO TABLE et_requested_orig_elements.

*        WHEN 'ANOTHERELEMENT'.
*          INSERT `` ...

        WHEN OTHERS.
*          RAISE EXCEPTION TYPE /dmo/cx_virtual_elements
*            EXPORTING
*              textid  = /dmo/cx_virtual_elements=>virtual_element_not_known
*              element = <fs_calc_element>
*              entity  = iv_entity.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
