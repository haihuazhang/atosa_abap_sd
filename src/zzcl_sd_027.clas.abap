CLASS zzcl_sd_027 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SD_027 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA:BEGIN OF ls_result,
           billingdocument TYPE string,
           language        TYPE string,
           longtextid      TYPE string,
           longtext        TYPE string,
         END OF ls_result,
         BEGIN OF ls_results,
           results LIKE TABLE OF ls_result,
         END OF ls_results,
         BEGIN OF ls_data,
           d LIKE ls_results,
         END OF ls_data.

    DATA lt_original_data TYPE STANDARD TABLE OF zc_ssd056 WITH DEFAULT KEY.
    DATA lv_sum_amount TYPE i_operationalacctgdocitem-amountincompanycodecurrency.

    lt_original_data = CORRESPONDING #( it_original_data ).

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

    SELECT a~fiscalyear,
           a~companycode,
           accountingdocument,
           accountingdocumentitem,
           postingkey,
           clearingjournalentry,
           amountincompanycodecurrency,
           paymentreference AS billingdocument
      FROM i_operationalacctgdocitem AS a
      JOIN zc_ssd056 AS b ON b~billingdocument = a~paymentreference
                         AND b~companycode = a~companycode
     WHERE followondocumenttype IS NOT INITIAL
      INTO TABLE @DATA(lt_clearing).

    LOOP AT lt_original_data INTO DATA(ls_original_data)
                              GROUP BY ( billingdocument = ls_original_data-billingdocument )
                             ASSIGNING FIELD-SYMBOL(<fs_group>).

      " Call API for get remarks
      TRY.
          DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
          DATA(lo_request) = lo_http_client->get_http_request(   ).
          lo_http_client->enable_path_prefix( ).

          DATA(lv_path) = |/API_BILLING_DOCUMENT_SRV/A_BillingDocument('{ <fs_group>-billingdocument }')/to_Text|.

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

          DATA(lt_remarks) = ls_data-d-results.
          SORT lt_remarks BY billingdocument longtextid language.
        CATCH cx_root.
      ENDTRY.

      LOOP AT GROUP <fs_group> ASSIGNING FIELD-SYMBOL(<fs_original_data>).

        READ TABLE lt_remarks INTO DATA(ls_remarks1) WITH KEY billingdocument = <fs_original_data>-billingdocument+2(8)
                                                              longtextid      = 'TX05'
                                                              language        = 'EN'
                                                              BINARY SEARCH.
        IF sy-subrc = 0.
          <fs_original_data>-invoiceremarks = ls_remarks1-longtext.
        ENDIF.

        READ TABLE lt_remarks INTO DATA(ls_remarks2) WITH KEY billingdocument = <fs_original_data>-billingdocument+2(8)
                                                              longtextid      = 'TX01'
                                                              language        = 'EN'
                                                              BINARY SEARCH.
        IF sy-subrc = 0.
          <fs_original_data>-internalremarks = ls_remarks2-longtext.
        ENDIF.

        SELECT *
          FROM @lt_clearing AS a
         WHERE a~billingdocument = @<fs_original_data>-billingdocument
          INTO TABLE @DATA(lt_temp).
        IF sy-subrc = 0.
          SORT lt_temp BY fiscalyear accountingdocument.
          " read the last entry
          READ TABLE lt_temp INTO DATA(ls_temp) INDEX lines( lt_temp ).
          IF ls_temp-clearingjournalentry IS NOT INITIAL.
            <fs_original_data>-paidtodate = <fs_original_data>-totalamount.
          ELSEIF ls_temp-postingkey = '06'.
            <fs_original_data>-paidtodate = <fs_original_data>-totalamount - ls_temp-amountincompanycodecurrency.
          ELSE.
            " Read the index of the last row with posting key = 06
            LOOP AT lt_temp TRANSPORTING NO FIELDS WHERE postingkey = '06'.
              DATA(lv_index) = sy-tabix.
            ENDLOOP.
            " sum amount
            LOOP AT lt_temp INTO ls_temp FROM lv_index.
              lv_sum_amount += ls_temp-amountincompanycodecurrency.
            ENDLOOP.
            <fs_original_data>-paidtodate = <fs_original_data>-totalamount - lv_sum_amount.
          ENDIF.
        ENDIF.

        IF <fs_original_data>-paidtodate = <fs_original_data>-totalamount.
          <fs_original_data>-documentstatus = 'C'.
        ELSE.
          <fs_original_data>-documentstatus = 'O'.
        ENDIF.

        CLEAR lv_sum_amount.
      ENDLOOP.

      CLEAR: lv_path,lv_response,ls_data,lt_remarks.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #(  lt_original_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
