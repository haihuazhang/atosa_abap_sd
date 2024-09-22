CLASS zzcl_sd_006 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

*    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SD_006 IMPLEMENTATION.


    METHOD if_sadl_exit_calc_element_read~calculate.
        DATA lt_original_data TYPE STANDARD TABLE OF zc_psd005 WITH DEFAULT KEY.
        lt_original_data = CORRESPONDING #( it_original_data ).
        LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
            DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
            DATA: lo_client_proxy      TYPE REF TO /iwbep/if_cp_client_proxy.

            " Find CA by Scenario ID
            lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
            DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
            lo_factory->query_ca(
                EXPORTING
                    is_query           = VALUE #( cscn_id_range = lr_cscn )
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
*               out->write( lx_http_dest_provider_error->get_text( ) ).
                EXIT.
            ENDTRY.

            TRY.
                DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

                DATA(lo_request) = lo_http_client->get_http_request(   ).

                DATA lv_languagecode TYPE spras.
                TRY.
                    lv_languagecode = cl_abap_context_info=>get_user_language_abap_format(  ).
                CATCH cx_abap_context_info_error.
                    "handle exception
                ENDTRY.

                lo_http_client->enable_path_prefix( ).

                DATA(lv_path) = |/API_SALES_ORDER_SRV/A_SalesOrderText(SalesOrder='{ <fs_original_data>-SalesDocument }',Language='{ lv_languagecode }',LongTextID='TX05')|.
                lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
                lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').

                lo_http_client->set_csrf_token(  ).

                DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).
                DATA(lv_response) = lo_response->get_text(  ).
                DATA(status) = lo_response->get_status( ).

                IF status-code = 200.
                    DATA lo_result TYPE REF TO data.
                    /ui2/cl_json=>deserialize(
                        EXPORTING
                            json = lv_response
                        CHANGING
                            data = lo_result
                    ).
                    ASSIGN COMPONENT 'd' OF STRUCTURE lo_result->* TO FIELD-SYMBOL(<fs_d>).
                    IF sy-subrc = 0.
                        ASSIGN COMPONENT 'LongText' OF STRUCTURE <fs_d>->* TO FIELD-SYMBOL(<fs_longtext>).
                        IF sy-subrc = 0.
                            <fs_original_data>-CustomerNote = <fs_longtext>->*.
                        ENDIF.
                    ENDIF.
                ENDIF.

            CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
            CATCH CX_WEB_HTTP_CLIENT_ERROR INTO DATA(lx_web_http_client_error).

            ENDTRY.

            SELECT SINGLE SoldToParty
            FROM I_SalesDocument
            WITH PRIVILEGED ACCESS
            WHERE SalesDocument = @<fs_original_data>-SalesDocument
            INTO @DATA(lv_soldto).

            SELECT SINGLE BusinessPartnerIDByExtSystem
            FROM I_BusinessPartner
            WITH PRIVILEGED ACCESS
            INNER JOIN I_SalesDocument
            WITH PRIVILEGED ACCESS
                ON I_SalesDocument~SoldToParty = I_BusinessPartner~BusinessPartner
                AND I_SalesDocument~SalesDocument = @<fs_original_data>-SalesDocument
            INTO @DATA(lv_bpidbyext).

            IF lv_bpidbyext IS INITIAL.
                <fs_original_data>-SoldToParty = lv_soldto.
            ELSE.
                lv_soldto = |{ lv_soldto ALPHA = OUT }|.
                CONCATENATE lv_soldto '/' lv_bpidbyext INTO <fs_original_data>-SoldToParty SEPARATED BY space.
            ENDIF.

        ENDLOOP.

        ct_calculated_data = CORRESPONDING #(  lt_original_data ).
    ENDMETHOD.


    METHOD if_sadl_exit_calc_element_read~get_calculation_info.
        LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
          CASE <fs_calc_element>.
            WHEN 'CUSTOMERNOTE'.
              INSERT `SALESDOCUMENT` INTO TABLE et_requested_orig_elements.

*            WHEN 'ANOTHERELEMENT'.
*              INSERT `` ...

            WHEN OTHERS.
*              RAISE EXCEPTION TYPE /dmo/cx_virtual_elements
*                EXPORTING
*                  textid  = /dmo/cx_virtual_elements=>virtual_element_not_known
*                  element = <fs_calc_element>
*                  entity  = iv_entity.
          ENDCASE.
        ENDLOOP.
    ENDMETHOD.
ENDCLASS.
