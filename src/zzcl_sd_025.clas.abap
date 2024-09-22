CLASS zzcl_sd_025 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SD_025 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA:BEGIN OF ls_result,
           product  TYPE string,
           language TYPE string,
           longtext TYPE string,
         END OF ls_result,

         BEGIN OF ls_results,
           results LIKE TABLE OF ls_result,
         END OF ls_results,

         BEGIN OF ls_data,
           d LIKE ls_results,
         END OF ls_data.

    DATA lt_original_data TYPE STANDARD TABLE OF zc_ssd053 WITH DEFAULT KEY.

    lt_original_data = CORRESPONDING #( it_original_data ).
    IF lt_original_data IS INITIAL.
      EXIT.
    ENDIF.

    " Find CA by Scenario ID
    cl_com_arrangement_factory=>create_instance( )->query_ca(
      EXPORTING
        is_query           = VALUE #( cscn_id_range = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ) )
      IMPORTING
        et_com_arrangement = DATA(lt_ca) ).
    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.

    " take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.

    " get destination based on Communication Arrangement and the service ID
    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
            comm_scenario  = 'YY1_API'
            service_id     = 'YY1_API_REST'
            comm_system_id = lo_ca->get_comm_system_id( ) ).

      CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
        EXIT.
    ENDTRY.

    TRY.
        DATA(lv_language) = cl_abap_context_info=>get_user_language_abap_format(  ).
      CATCH cx_abap_context_info_error.
    ENDTRY.

    SELECT *
      FROM zc_tsd013
       FOR ALL ENTRIES IN @lt_original_data
     WHERE deliverynumber   = @lt_original_data-deliverydocument
       AND deliveryitem     = @lt_original_data-deliverydocumentitem
       AND pickingcompleted = @abap_true
      INTO TABLE @DATA(lt_sd013).

    SORT lt_sd013 BY deliverynumber ASCENDING
                     deliveryitem   ASCENDING
                     scanneddate    DESCENDING.

    SELECT product,
           productname
      FROM i_producttext
       FOR ALL ENTRIES IN @lt_original_data
     WHERE product = @lt_original_data-product
       AND language = @lv_language
      INTO TABLE @DATA(lt_productname).

    SORT lt_productname BY product.

    SELECT a~deliverydocument,
           a~lastchangedbyuser,
           a~lastchangedate,
           b~personfullname
      FROM i_deliverydocument AS a
      LEFT JOIN i_businessuserbasic AS b ON b~userid = a~lastchangedbyuser
       FOR ALL ENTRIES IN @lt_original_data
     WHERE deliverydocument = @lt_original_data-deliverydocument
      INTO TABLE @DATA(lt_delivery).

    SORT lt_delivery BY deliverydocument.

    LOOP AT lt_original_data INTO DATA(ls_original_data)
                              GROUP BY ( product = ls_original_data-product )
                             ASSIGNING FIELD-SYMBOL(<fs_group>).

      " Call API for get product description
      TRY.
          DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
          DATA(lo_request) = lo_http_client->get_http_request(   ).
          lo_http_client->enable_path_prefix( ).

          DATA(lv_path) = |/API_PRODUCT_SRV/A_Product('{ <fs_group>-product }')/to_ProductBasicText|.
          REPLACE ALL OCCURRENCES OF ` ` IN lv_path WITH '%20'.

          lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
          lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).

          lo_http_client->set_csrf_token(  ).

          DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).
          DATA(lv_response) = lo_response->get_text(  ).
          DATA(lv_status)   = lo_response->get_status( ).

          /ui2/cl_json=>deserialize(
              EXPORTING
                  json = lv_response
              CHANGING
                  data = ls_data
          ).

          DATA(lt_product_text) = ls_data-d-results.
          SORT lt_product_text BY product language.
        CATCH cx_root.
      ENDTRY.

      LOOP AT GROUP <fs_group> ASSIGNING FIELD-SYMBOL(<fs_original_data>).
        READ TABLE lt_product_text INTO DATA(ls_product_text) WITH KEY product  = <fs_original_data>-product
                                                                       language = 'EN'
                                                                       BINARY SEARCH.
        IF sy-subrc = 0.
          <fs_original_data>-itemdescription = ls_product_text-longtext.
        ELSE.
          READ TABLE lt_productname INTO DATA(ls_productname) WITH KEY product = <fs_original_data>-product BINARY SEARCH.
          IF sy-subrc = 0.
            <fs_original_data>-itemdescription = ls_productname-productname.
          ENDIF.
        ENDIF.

        " Call BOI for get delivery's QuantityPicked and Remarks
        READ ENTITIES OF i_outbounddeliverytp
          ENTITY outbounddeliveryitem
            ALL FIELDS WITH VALUE #( ( %key-outbounddelivery     = <fs_original_data>-deliverydocument
                                       %key-outbounddeliveryitem = <fs_original_data>-deliverydocumentitem ) )
            RESULT FINAL(lt_item)

          ENTITY outbounddeliverytext
            ALL FIELDS WITH VALUE #( ( %key-outbounddelivery = <fs_original_data>-deliverydocument
                                       %key-language         = lv_language
                                       %key-longtextid       = 'TX07' ) )
            RESULT FINAL(lt_text)
            FAILED FINAL(ls_failed).

        IF ls_failed-outbounddeliveryitem IS INITIAL.
          READ TABLE lt_item INTO DATA(ls_item) INDEX 1.
          IF sy-subrc = 0.
            <fs_original_data>-quantitypicked = ls_item-pickquantityinbaseunit.
          ENDIF.
        ENDIF.

        IF ls_failed-outbounddeliverytext IS INITIAL.
          READ TABLE lt_text INTO DATA(ls_text) INDEX 1.
          IF sy-subrc = 0.
            <fs_original_data>-remarks = ls_text-longtext.
          ENDIF.
        ENDIF.

        READ TABLE lt_sd013 INTO DATA(ls_sd013) WITH KEY deliverynumber = <fs_original_data>-deliverydocument
                                                         deliveryitem   = <fs_original_data>-deliverydocumentitem
                                                         BINARY SEARCH.
        IF sy-subrc = 0.
          <fs_original_data>-firstpickdate   = ls_sd013-scanneddate.
          <fs_original_data>-warehousepicker = ls_sd013-scannedusername.
        ELSEIF <fs_original_data>-overallpickingstatus <> 'A'.
          READ TABLE lt_delivery INTO DATA(ls_delivery) WITH KEY deliverydocument = <fs_original_data>-deliverydocument
                                                                 BINARY SEARCH.
          IF sy-subrc = 0.
            <fs_original_data>-firstpickdate   = COND #( WHEN ls_delivery-lastchangedate IS NOT INITIAL
                                                         THEN ls_delivery-lastchangedate
                                                         ELSE <fs_original_data>-creationdate ).

            <fs_original_data>-warehousepicker = COND #( WHEN ls_delivery-personfullname IS NOT INITIAL
                                                         THEN ls_delivery-personfullname
                                                         ELSE <fs_original_data>-personfullname ).
          ENDIF.
        ENDIF.
      ENDLOOP.

      CLEAR: lv_path,lv_response,ls_data,lt_product_text.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #(  lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
