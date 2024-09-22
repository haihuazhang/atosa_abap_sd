CLASS LHC_ZR_TSD015 DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZR_TSD015
        RESULT result,
      createScannedRecord FOR MODIFY
        IMPORTING keys FOR ACTION zr_tsd015~createScannedRecord,
      getOpenQty FOR READ
        IMPORTING keys FOR FUNCTION zr_tsd015~getOpenQty RESULT result.
ENDCLASS.

CLASS LHC_ZR_TSD015 IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD createScannedRecord.
    DATA : lt_tsd015 TYPE TABLE FOR CREATE zr_tsd015.

    ASSERT lines( keys ) > 0.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc <> 0.
        RETURN.
    ENDIF.

    SELECT SINGLE * FROM ZR_SSD021 WHERE OutboundDelivery = @<key>-%param-OutboundDelivery "#EC CI_ALL_FIELDS_NEEDED
                                      AND OutboundDeliveryItem = @<key>-%param-OutboundDeliveryItem
        INTO @DATA(ls_outbounddeliveryitem).

    READ ENTITIES OF ZR_TSD015 IN LOCAL MODE
    ENTITY ZR_TSD015
    EXECUTE getOpenQty FROM VALUE #( ( %param-OutboundDelivery = ls_outbounddeliveryitem-OutboundDelivery
                                       %param-OutboundDeliveryItem = ls_outbounddeliveryitem-OutboundDeliveryItem ) )
    RESULT FINAL(lt_open_qty).

    IF <key>-%param-ScannedQuantity > lt_open_qty[ 1 ]-%param.
        "throw error message 016: "The input qty exceeds the order qty. Please check."
        reported-zr_tsd015 = VALUE #( ( %cid = <key>-%cid
                                %msg = new_message( id = 'ZZSD' number = 016 severity = if_abap_behv_message=>severity-error  )
                                ) ).
        failed-zr_tsd015 = VALUE #( ( %cid = <key>-%cid ) ).
    ELSE.
        lt_tsd015 = VALUE #( ( %cid = <key>-%cid
                               DeliveryNumber = ls_outbounddeliveryitem-OutboundDelivery
                               DeliveryItem = ls_outbounddeliveryitem-OutboundDeliveryItem
                               Material = ls_outbounddeliveryitem-Material
                               Plant = ls_outbounddeliveryitem-Plant
                               StorageLocation = ls_outbounddeliveryitem-StorageLocation
                               Scannedquantity = <key>-%param-ScannedQuantity
                               Unitofmeasure = ls_outbounddeliveryitem-DeliveryQuantityUnit ) ).

        MODIFY ENTITIES OF zr_tsd015 IN LOCAL MODE
        ENTITY zr_tsd015
        CREATE FIELDS ( DeliveryNumber DeliveryItem Material Plant StorageLocation Scannedquantity Unitofmeasure )
        WITH lt_tsd015
        MAPPED mapped
        REPORTED reported
        FAILED failed.
    ENDIF.



  ENDMETHOD.

  METHOD getOpenQty.
    ASSERT lines( keys ) > 0.

    DATA lv_openqty TYPE i.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc <> 0.
        RETURN.
    ENDIF.

    SELECT OutboundDelivery,
           OutboundDeliveryItem,
           TotalQty
    FROM ZR_SSD021
    WHERE OutboundDelivery = @<key>-%param-OutboundDelivery
    INTO TABLE @DATA(lt_deliveryitem).

    IF sy-subrc = 0.
        LOOP AT lt_deliveryitem ASSIGNING FIELD-SYMBOL(<fs_deliveryitem>).
            READ ENTITIES OF I_OutboundDeliveryTP
            ENTITY OutboundDeliveryItem
            FIELDS ( PickQuantityInOrderUnit ) WITH VALUE #( ( %tky-OutboundDelivery = <fs_deliveryitem>-OutboundDelivery
                                                               %tky-OutboundDeliveryItem = <fs_deliveryitem>-OutboundDeliveryItem ) )
            RESULT FINAL(LT_PICKEDQTY).

            IF lines( LT_PICKEDQTY ) > 0.
                lv_openqty = <fs_deliveryitem>-TotalQty - LT_PICKEDQTY[ 1 ]-PickQuantityInOrderUnit.
                result = VALUE #( ( %cid =  <key>-%cid %param = lv_openqty ) ).
            ENDIF.
        ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
