CLASS zzcl_sd_013 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SD_013 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    TYPES:BEGIN OF ty_data,
            billingdocument TYPE string,
            language        TYPE string,
            longtextid      TYPE string,
            longtext        TYPE string,
          END OF ty_data.
    DATA:BEGIN OF ls_data,
           d TYPE ty_data,
         END OF ls_data.

    DATA lt_original_data TYPE STANDARD TABLE OF zc_psd010 WITH DEFAULT KEY.

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
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

        DATA(lo_request) = lo_http_client->get_http_request(   ).

        TRY.
            DATA(lv_language) = cl_abap_context_info=>get_user_language_abap_format(  ).
          CATCH cx_abap_context_info_error.
        ENDTRY.

        lo_http_client->enable_path_prefix( ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
      CATCH cx_root.
    ENDTRY.

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).

      " Billing Header Text
      TRY.
          DATA(lv_path) = |/API_BILLING_DOCUMENT_SRV/A_BillingDocumentText(BillingDocument='{ <fs_original_data>-billingdocument }',Language='EN',LongTextID='TX05')|.

          lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
          lo_http_client->set_csrf_token(  ).

          DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).

          DATA(lv_response) = lo_response->get_text(  ).
          DATA(lv_status) = lo_response->get_status(  ).

          /ui2/cl_json=>deserialize(
              EXPORTING
                  json = lv_response
              CHANGING
                  data = ls_data
          ).

          <fs_original_data>-invoiceremarks = ls_data-d-longtext.

          CLEAR: lv_path,lv_response,ls_data.
        CATCH cx_root.
      ENDTRY.


      " Attachment
      TYPES:
        BEGIN OF ts_key,
          billing_document TYPE i_billingdocument-billingdocument,
        END OF ts_key.

      DATA(ls_key) = VALUE ts_key( billing_document = <fs_original_data>-billingdocument ).

      DATA(lv_key) = xco_cp_json=>data->from_abap( ls_key )->apply( VALUE #(
        ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).

      SELECT pdf
        FROM zzt_prt_record
       WHERE template_uuid = ( SELECT uuid FROM zzt_prt_template WHERE template_name = 'LOB04-022' )
         AND provided_keys = @lv_key
       ORDER BY created_at DESCENDING
        INTO TABLE @DATA(lt_pdf) UP TO 1 ROWS.
      IF sy-subrc = 0.
        <fs_original_data>-mimetype = |application/pdf|.
        <fs_original_data>-pdf      = lt_pdf[ 1 ]-pdf.
      ENDIF.

      CLEAR lt_pdf.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #(  lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
