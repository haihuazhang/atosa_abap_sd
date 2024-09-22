CLASS zzcl_sd_003 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SD_003 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data TYPE STANDARD TABLE OF ZC_SSD021 WITH DEFAULT KEY.
    lt_original_data = CORRESPONDING #( it_original_data ).
    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
        SELECT SINGLE CustomerReturnDelivery, CustomerReturnDeliveryItem
        FROM I_CustomerReturnDeliveryItem
        WHERE CustomerReturnDelivery = @<fs_original_data>-OutboundDelivery
          AND CustomerReturnDeliveryItem = @<fs_original_data>-OutboundDeliveryItem
        INTO @DATA(ls_return_item).

        IF sy-subrc <> 0.
            READ ENTITIES OF I_OutboundDeliveryTP
            ENTITY OutboundDeliveryItem
            FIELDS ( PickQuantityInOrderUnit  ) WITH VALUE #( ( %tky-OutboundDelivery = <fs_original_data>-OutboundDelivery
                                                %tky-OutboundDeliveryItem = <fs_original_data>-OutboundDeliveryItem ) )
            RESULT FINAL(LT_PICKEDQTY).
            if lines( LT_PICKEDQTY ) > 0.
                <fs_original_data>-PickedQty = LT_PICKEDQTY[ 1 ]-PickQuantityInOrderUnit.
                <fs_original_data>-OpenQty = <fs_original_data>-TotalQty - LT_PICKEDQTY[ 1 ]-PickQuantityInOrderUnit.
            endif.
        ELSE.
            READ ENTITIES OF I_CUSTOMERRETURNSDELIVERYTP
            ENTITY CustomerReturnsDeliveryItem
            FIELDS ( PickQuantityInBaseUnit ) WITH VALUE #( ( %tky-CustomerReturnDelivery = <fs_original_data>-OutboundDelivery
                                                              %tky-CustomerReturnDeliveryItem = <fs_original_data>-OutboundDeliveryItem ) )
            RESULT FINAL(LT_RETURN_PICKEDQTY).
            IF lines( LT_RETURN_PICKEDQTY ) > 0.
                <fs_original_data>-PickedQty = LT_RETURN_PICKEDQTY[ 1 ]-PickQuantityInBaseUnit.
                <fs_original_data>-OpenQty = <fs_original_data>-TotalQty - LT_RETURN_PICKEDQTY[ 1 ]-PickQuantityInBaseUnit.
            ENDIF.
        ENDIF.



    ENDLOOP.

    ct_calculated_data = CORRESPONDING #(  lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
      CASE <fs_calc_element>.
        WHEN 'PickedQty'.
        WHEN 'OpenQty'.
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
