CLASS lhc_zr_tsd001 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zr_tsd001
        RESULT result,
      check FOR VALIDATE ON SAVE
        IMPORTING keys FOR zr_tsd001~check.
ENDCLASS.

CLASS lhc_zr_tsd001 IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD check.

    READ ENTITIES OF zr_tsd001
    ENTITY zr_tsd001
    FIELDS ( ProductGroup Product ZWarrantyType )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    IF lt_data IS NOT INITIAL.
      SELECT * "#EC CI_ALL_FIELDS_NEEDED
      FROM I_Product
      WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_data
      WHERE productgroup = @lt_data-ProductGroup
      INTO TABLE @DATA(lt_productgroup).
      SORT lt_productgroup BY productgroup.
      SELECT * "#EC CI_ALL_FIELDS_NEEDED
      FROM I_Product
      WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_data
      WHERE product      = @lt_data-Product
      INTO TABLE @DATA(lt_product).
      SORT lt_product BY product.
    ENDIF.

    LOOP AT lt_data INTO DATA(ls_data).
      TRANSLATE ls_data-ZWarrantyType TO UPPER CASE.
      TRANSLATE ls_data-ZWarrantyDefalut TO UPPER CASE.
      IF ls_data-ZWarrantyDefalut IS NOT INITIAL AND ls_data-ZWarrantyDefalut <> 'X'.
        INSERT VALUE #( uuid                         = ls_data-uuid
                          %msg                       = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                              text     = 'Please enter "X" to set the "Default" mark.' )
                          %element-zwarrantytype = if_abap_behv=>mk-on
                        ) INTO TABLE reported-zr_tsd001.
        INSERT VALUE #( uuid = ls_data-uuid ) INTO TABLE failed-zr_tsd001.
      ENDIF.
      IF ls_data-ZWarrantyType IS NOT INITIAL AND ls_data-ZWarrantyType <> 'STANDARD' AND ls_data-ZWarrantyType <> 'EXTEND'.
        INSERT VALUE #( uuid                         = ls_data-uuid
                          %msg                       = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                              text     = 'Warranty Type ERROR' )
                          %element-zwarrantytype = if_abap_behv=>mk-on
                        ) INTO TABLE reported-zr_tsd001.
        INSERT VALUE #( uuid = ls_data-uuid ) INTO TABLE failed-zr_tsd001.
      ENDIF.
      IF ls_data-ProductGroup IS NOT INITIAL.
      READ TABLE lt_productgroup INTO DATA(ls_productgroup) WITH KEY ProductGroup = ls_data-ProductGroup BINARY SEARCH.
      IF SY-SUBRC = 0.
        IF ls_data-Product IS NOT INITIAL.
          READ TABLE lt_productgroup INTO DATA(ls_productgroup1) WITH KEY ProductGroup = ls_data-ProductGroup
                                                                          Product      = ls_data-Product.
          IF sy-subrc <> 0.
            INSERT VALUE #( uuid                     = ls_data-uuid
                          %msg                       = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                              text     = 'The material group and material number are inconsistent' )
                          %element-productgroup = if_abap_behv=>mk-on
                        ) INTO TABLE reported-zr_tsd001.
            INSERT VALUE #( uuid = ls_data-uuid ) INTO TABLE failed-zr_tsd001.
          ENDIF.
        ENDIF.
      ELSE.
        INSERT VALUE #( uuid                         = ls_data-uuid
                          %msg                       = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                              text     = 'ProductGroup not exist' )
                          %element-productgroup = if_abap_behv=>mk-on
                        ) INTO TABLE reported-zr_tsd001.
        INSERT VALUE #( uuid = ls_data-uuid ) INTO TABLE failed-zr_tsd001.
      ENDIF.
      ENDIF.
      IF ls_data-Product IS NOT INITIAL.
      READ TABLE lt_product INTO DATA(ls_product) WITH KEY Product = ls_data-Product BINARY SEARCH.
      IF SY-SUBRC = 0.
        IF ls_data-ProductGroup IS NOT INITIAL.
          IF ls_data-ProductGroup <> ls_productgroup-ProductGroup.
            INSERT VALUE #( uuid                         = ls_data-uuid
                          %msg                           = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                                  text     = 'The material group and material number are inconsistent' )
                          %element-product               = if_abap_behv=>mk-on
                        ) INTO TABLE reported-zr_tsd001.
            INSERT VALUE #( uuid = ls_data-uuid ) INTO TABLE failed-zr_tsd001.
          ENDIF.
        ENDIF.
      ELSE.
        INSERT VALUE #( uuid                         = ls_data-uuid
                          %msg                       = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                              text     = 'Product not exist' )
                          %element-product = if_abap_behv=>mk-on
                        ) INTO TABLE reported-zr_tsd001.
        INSERT VALUE #( uuid = ls_data-uuid ) INTO TABLE failed-zr_tsd001.
      ENDIF.
      ENDIF.
    ENDLOOP.



  ENDMETHOD.

ENDCLASS.
