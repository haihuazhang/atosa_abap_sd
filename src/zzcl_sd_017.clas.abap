CLASS zzcl_sd_017 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

*    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SD_017 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data TYPE STANDARD TABLE OF zc_psd003 WITH DEFAULT KEY.
    lt_original_data = CORRESPONDING #( it_original_data ).
    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
      READ ENTITIES OF i_outbounddeliverytp
         ENTITY OutboundDeliveryItemText
         FIELDS ( longtext  ) WITH VALUE #( ( %tky-outbounddelivery = <fs_original_data>-deliverydocument
                                              %tky-OutboundDeliveryItem = <fs_original_data>-DeliveryDocumentItem
                                              %tky-longtextid = 'TX07'
                                              %tky-language = 'E' ) )
      RESULT FINAL(lt_text).
      IF lines( lt_text ) > 0.
        <fs_original_data>-longtextitem = lt_text[ 1 ]-longtext.
      ELSE.
        READ ENTITIES OF i_customerreturnsdeliverytp
          ENTITY CustReturnsDeliveryItemText
          FIELDS ( longtext  ) WITH VALUE #( ( %tky-customerreturndelivery = <fs_original_data>-deliverydocument
                                               %tky-CustomerReturnDeliveryItem = <fs_original_data>-DeliveryDocumentItem
                                               %tky-longtextid = 'TX07'
                                               %tky-language = 'E' ) )
       RESULT FINAL(lt_text1).
        IF lines( lt_text1 ) > 0.
          <fs_original_data>-longtextitem = lt_text1[ 1 ]-longtext.
        ENDIF.
      ENDIF.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #(  lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
      CASE <fs_calc_element>.
        WHEN 'LONGTEXT'.
          INSERT `DELIVERYDOCUMENT` INTO TABLE et_requested_orig_elements.

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
