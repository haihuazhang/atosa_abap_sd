CLASS lhc_zr_tsd012 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zr_tsd012
        RESULT result,
      createScannedRecord FOR MODIFY
        IMPORTING keys FOR ACTION zr_tsd012~createScannedRecord.
ENDCLASS.

CLASS lhc_zr_tsd012 IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD createScannedRecord.
    DATA : lt_tsd012_create          TYPE TABLE FOR CREATE zr_tsd012.
    DATA : lt_tsd012_update          TYPE TABLE FOR UPDATE zr_tsd012.
    ASSERT lines( keys ) > 0.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT SINGLE * FROM zr_ssd018 WHERE OutboundDelivery = @<key>-%param-OutboundDelivery "#EC CI_ALL_FIELDS_NEEDED
                                      AND OutboundDeliveryItem = @<key>-%param-OutboundDeliveryItem
        INTO @DATA(ls_outbounddeliveryitem).

      IF <key>-%param-ScannedQuantity > ls_outbounddeliveryitem-ActualDeliveryQuantity.
        "throw error message 016: "The input qty exceeds the order qty. Please check."
        reported-zr_tsd012 = VALUE #( ( %cid = <key>-%cid
                                %msg = new_message( id = 'ZZSD' number = 016 severity = if_abap_behv_message=>severity-error  )
                                DeliveryItem = ls_outbounddeliveryitem-OutboundDeliveryItem
                                DeliveryNumber = ls_outbounddeliveryitem-OutboundDelivery
*                                Material = ls_outbounddeliveryitem-Product
*                                SerialNumber = ls_scanned_record-SerialNumber
                                ) ).
        failed-zr_tsd012 = VALUE #( ( %cid = <key>-%cid
                                      DeliveryItem = ls_outbounddeliveryitem-OutboundDeliveryItem
                                      DeliveryNumber = ls_outbounddeliveryitem-OutboundDelivery
*                                      Material = ls_scanned_record-Material
*                                      SerialNumber = ls_scanned_record-SerialNumber
                                       ) ).

      ELSE.
        SELECT SINGLE DeliveryNumber,
                      DeliveryItem
                      FROM zr_tsd012
                      WHERE DeliveryNumber = @ls_outbounddeliveryitem-OutboundDelivery
                        AND DeliveryItem = @ls_outbounddeliveryitem-OutboundDeliveryItem
        INTO @DATA(ls_scanned_item).

        IF sy-subrc <> 0.

          lt_tsd012_create = VALUE #( ( %cid = <key>-%cid
                       DeliveryNumber = ls_outbounddeliveryitem-OutboundDelivery
                       DeliveryItem = ls_outbounddeliveryitem-OutboundDeliveryItem
                       Material = ls_outbounddeliveryitem-Product
*                               SerialNumber = ls_serialnumber-SerialNumber
                       Plant = ls_outbounddeliveryitem-Plant
                       StorageLocation = ls_outbounddeliveryitem-StorageLocation
*                               OldSerialNumber = COND #( WHEN lv_oldserialnumber NE '' THEN lv_oldserialnumber ELSE ''
                       Scannedquantity = <key>-%param-ScannedQuantity
                       Unitofmeasure = ls_outbounddeliveryitem-DeliveryQuantityUnit
                        ) ).
          MODIFY ENTITIES OF zr_tsd012 IN LOCAL MODE
              ENTITY zr_tsd012
              CREATE  FIELDS ( DeliveryNumber DeliveryItem Material Plant StorageLocation Scannedquantity Unitofmeasure ) WITH lt_tsd012_create
                        MAPPED mapped
                        REPORTED reported
                        FAILED failed.

        ELSE.
          lt_tsd012_update = VALUE #( (
*                        %cid = <key>-%cid
                       DeliveryNumber = ls_outbounddeliveryitem-OutboundDelivery
                       DeliveryItem = ls_outbounddeliveryitem-OutboundDeliveryItem
*                       Material = ls_outbounddeliveryitem-Product
*                               SerialNumber = ls_serialnumber-SerialNumber
*                       Plant = ls_outbounddeliveryitem-Plant
*                       StorageLocation = ls_outbounddeliveryitem-StorageLocation
*                               OldSerialNumber = COND #( WHEN lv_oldserialnumber NE '' THEN lv_oldserialnumber ELSE ''
                       Scannedquantity = <key>-%param-ScannedQuantity
*                       Unitofmeasure = ls_outbounddeliveryitem-DeliveryQuantityUnit
                        ) ).
          MODIFY ENTITIES OF zr_tsd012 IN LOCAL MODE
              ENTITY zr_tsd012
              UPDATE  FIELDS ( Scannedquantity  ) WITH lt_tsd012_UPDATE
                        MAPPED mapped
                        REPORTED reported
                        FAILED failed.

        ENDIF.


      ENDIF.

    ENDIF.
  ENDMETHOD.

ENDCLASS.
