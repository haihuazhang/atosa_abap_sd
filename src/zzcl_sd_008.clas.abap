CLASS zzcl_sd_008 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

*    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SD_008 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data TYPE STANDARD TABLE OF zc_psd015 WITH DEFAULT KEY.
    lt_original_data = CORRESPONDING #( it_original_data ).
    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
*      <fs_original_data>-DaysToFlight =  <fs_original_data>-FlightDate - lv_today.
      READ ENTITIES OF I_OutboundDeliveryTP
         ENTITY OutboundDeliveryItemText
*         FIELDS ( LongText  ) WITH VALUE #( (
         FIELDS ( LongText  ) WITH VALUE #( ( %tky-OutboundDeliveryItem = <fs_original_data>-DeliveryDocumentItem
                                              %tky-OutboundDelivery = <fs_original_data>-DeliveryDocument
                                              %tky-LongTextID = 'Z001'
                                              %tky-Language = 'E' ) )
      RESULT FINAL(lt_text).
      IF lines( lt_text ) > 0.
        <fs_original_data>-MaterialNote = lt_text[ 1 ]-LongText.
      ENDIF.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #(  lt_original_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
