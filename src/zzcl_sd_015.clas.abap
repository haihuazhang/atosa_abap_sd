CLASS zzcl_sd_015 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS get_backorder IMPORTING io_request  TYPE REF TO if_rap_query_request
                                    io_response TYPE REF TO if_rap_query_response
                          RAISING   cx_rap_query_prov_not_impl
                                    cx_rap_query_provider.
ENDCLASS.



CLASS ZZCL_SD_015 IMPLEMENTATION.


  METHOD get_backorder.
    TRY.

        DATA: lt_funcs TYPE TABLE OF zr_ssd030.

        DATA : lr_salesorder TYPE RANGE OF i_salesdocumentitem-salesdocument.
        DATA : lr_plant TYPE RANGE OF i_salesdocumentitem-plant.
        DATA : lr_soldtoparty TYPE RANGE OF i_salesdocumentitem-soldtoparty.
        DATA : lr_material TYPE RANGE OF i_salesdocumentitem-material.

        DATA(lo_filter) = io_request->get_filter(  ).
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).

        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'SALESDOCUMENT'.
              MOVE-CORRESPONDING ls_filter-range TO lr_salesorder.
            WHEN 'PLANT'.
              MOVE-CORRESPONDING ls_filter-range TO lr_plant.
            WHEN 'CUSTOMER'.
              MOVE-CORRESPONDING ls_filter-range TO lr_soldtoparty.
            WHEN 'MATERIAL'.
              MOVE-CORRESPONDING ls_filter-range TO lr_material.

          ENDCASE.

        ENDLOOP.

        SELECT *
        FROM zr_ssd029
        WHERE salesdocument IN @lr_salesorder
        AND   plant         IN @lr_plant
        AND   customer   IN @lr_soldtoparty
        AND   material   IN @lr_material
        INTO TABLE @DATA(lt_funcs1).
        DELETE lt_funcs1 WHERE material IS INITIAL.
        DELETE lt_funcs1 WHERE salesdocument IS INITIAL.
        SELECT storage_location
        FROM ztsd014
        WHERE storage_location IS NOT INITIAL
        INTO TABLE @DATA(lt_ztsd014).
        SORT lt_ztsd014 BY storage_location.


        MOVE-CORRESPONDING lt_funcs1 TO lt_funcs.
        LOOP AT lt_funcs INTO DATA(ls_funcs).
          READ TABLE lt_ztsd014 INTO DATA(ls_ztsd014) WITH KEY storage_location = ls_funcs-storagelocation BINARY SEARCH.
          IF sy-subrc = 0.
            DELETE lt_funcs[].
          ENDIF.
        ENDLOOP.
        TYPES:BEGIN OF ty_storge,
                material                     TYPE string,
                plant                        TYPE string,
                matlwrhsstkqtyinmatlbaseunit TYPE zzesd073,
              END OF ty_storge.
        TYPES:BEGIN OF ty_commit,
                material TYPE string,
                plant    TYPE string,
                openqty  TYPE zzesd073,
              END OF ty_commit.
        DATA: lt_data TYPE TABLE OF ty_storge.
        DATA: lt_commit TYPE TABLE OF ty_commit,
              ls_commit TYPE ty_commit.
        SORT lt_funcs BY material plant salesdocument.
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
            EXIT.
        ENDTRY.

        TRY.

            TRY.
                DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
              CATCH cx_web_http_client_error.
            ENDTRY.

            DATA(lo_request) = lo_http_client->get_http_request(   ).

            DATA : lv_languagecode TYPE spras.
            TRY.
                lv_languagecode = cl_abap_context_info=>get_user_language_abap_format(  ).
              CATCH cx_abap_context_info_error.
                "handle exception
            ENDTRY.


            lo_http_client->enable_path_prefix( ).
*            DATA(lv_path) = |{ '/API_MATERIAL_STOCK_SRV/A_MaterialStock(''' }{ ls_funcs-material }{ ''')/to_MatlStkInAcctMod' }|.
            DATA(lv_path) = |{ '/API_MATERIAL_STOCK_SRV/A_MatlStkInAcctMod' }|.
            REPLACE ALL OCCURRENCES OF ` ` IN lv_path WITH '%20'.

*                lv_path = cl_web_http_utility=>escape_url( lv_path ).

            lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
            lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').

            TRY.
                lo_http_client->set_csrf_token(  ).

                DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).
              CATCH cx_web_http_client_error.
            ENDTRY.

            DATA(lv_response) = lo_response->get_text(  ).

            TYPES:BEGIN OF ty_t,
                    id   TYPE string,
                    type TYPE string,
                    uri  TYPE string,
                  END OF ty_t.
            TYPES:BEGIN OF ty_ms1,
                    uri TYPE string,
                  END OF ty_ms1.
            TYPES:BEGIN OF ty_ms,
                    _deferred TYPE ty_ms1,
                  END OF ty_ms.
            TYPES:BEGIN OF ty_tab,
                    _metadata                    TYPE ty_t,
                    material                     TYPE string,
                    plant                        TYPE string,
                    storagelocation              TYPE string,
                    batch                        TYPE string,
                    supplier                     TYPE string,
                    customer                     TYPE string,
                    wbselementinternalid         TYPE string,
                    sddocument                   TYPE string,
                    sddocumentitem               TYPE string,
                    inventoryspecialstocktype    TYPE string,
                    inventorystocktype           TYPE string,
                    materialbaseunit             TYPE meins,
                    matlwrhsstkqtyinmatlbaseunit TYPE zzesd073,
                    to_materialserialnumber      TYPE ty_ms,
                    to_materialstock             TYPE ty_ms,
                  END OF ty_tab.
            DATA:BEGIN OF ls_data,
                   results TYPE TABLE OF ty_tab,
                 END OF ls_data.
            DATA:BEGIN OF lo_error,
                   d LIKE ls_data,
                 END OF lo_error.
            DATA: lt_storge TYPE TABLE OF ty_storge,
                  ls_storge TYPE ty_storge.
*                      "Error handling here
*                      "handle odata error message here
            /ui2/cl_json=>deserialize(
                EXPORTING
                    json = lv_response
                CHANGING
                    data = lo_error
            ).
            LOOP AT lo_error-d-results INTO DATA(ls_results).
              IF ls_results-storagelocation = 'AREG' AND ls_results-inventorystocktype = '01'.
                MOVE-CORRESPONDING ls_results TO ls_storge.
                COLLECT ls_storge INTO lt_storge.
              ENDIF.
            ENDLOOP.
            SORT lt_storge BY material plant.
          CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        ENDTRY.
        LOOP AT lt_funcs INTO ls_funcs.
          CLEAR:ls_funcs-inventoryquantity,ls_funcs-backorderedquantity,ls_funcs-balance,ls_funcs-openvalues.
          TRY.
              ls_funcs-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
          ls_funcs-conditionamount = ls_funcs-conditionamount / ls_funcs-orderquantity.
          IF ls_funcs-flag = ''.
            ls_funcs-openqty = ls_funcs-orderquantity - ls_funcs-openqty.
          ENDIF.
          ls_funcs-openvalues = ls_funcs-openqty * ls_funcs-conditionamount.
          SORT lt_data BY material plant.
*          READ TABLE lt_data INTO DATA(ls_data1) WITH KEY material = ls_funcs-material
*                                                         plant = ls_funcs-plant BINARY SEARCH.
*          IF sy-subrc = 0.
*            ls_funcs-inventoryquantity = ls_data1-matlwrhsstkqtyinmatlbaseunit.
*          ELSE.
          READ TABLE lt_storge INTO ls_storge WITH KEY material = ls_funcs-material
                                                       plant = ls_funcs-plant BINARY SEARCH.
          IF sy-subrc = 0.
            ls_funcs-inventoryquantity = ls_storge-matlwrhsstkqtyinmatlbaseunit.
          ENDIF.
*            APPEND LINES OF lt_storge TO lt_data.
*          ENDIF.
          MOVE-CORRESPONDING ls_funcs TO ls_commit.
          COLLECT ls_commit INTO lt_commit.
          MODIFY lt_funcs FROM ls_funcs.
          CLEAR:ls_funcs,ls_storge,ls_commit.
        ENDLOOP.
        SORT lt_commit BY material plant.
        DATA:lv_str TYPE string.
        DATA:lv_balance TYPE zzesd073.
        LOOP AT lt_funcs ASSIGNING FIELD-SYMBOL(<fs_funcs>).
          IF sy-tabix = 1.
            lv_str = <fs_funcs>-material && <fs_funcs>-plant.
            <fs_funcs>-balance = <fs_funcs>-inventoryquantity - <fs_funcs>-openqty.
            lv_balance = <fs_funcs>-balance.
          ELSE.
            DATA(lv_mp) = <fs_funcs>-material && <fs_funcs>-plant.
            IF lv_mp = lv_str.
              <fs_funcs>-balance = lv_balance - <fs_funcs>-openqty.
              lv_balance = <fs_funcs>-balance.
            ELSE.
              lv_str = <fs_funcs>-material && <fs_funcs>-plant.
              lv_balance = <fs_funcs>-inventoryquantity - <fs_funcs>-openqty.
              <fs_funcs>-balance = lv_balance.
            ENDIF.
          ENDIF.
        ENDLOOP.
        LOOP AT lt_funcs INTO ls_funcs.
          CLEAR:ls_funcs-confddelivqtyinorderqtyunit.
          READ TABLE lt_commit INTO ls_commit WITH KEY material = ls_funcs-material
                                                       plant = ls_funcs-plant BINARY SEARCH.
          IF sy-subrc = 0.
            ls_funcs-confddelivqtyinorderqtyunit = ls_commit-openqty.
            ls_funcs-backorderedquantity = ls_funcs-confddelivqtyinorderqtyunit - ls_funcs-inventoryquantity.
            IF ls_funcs-backorderedquantity <= 0.
              ls_funcs-backorderedquantity = 0.
            ENDIF.
          ENDIF.
          MODIFY lt_funcs FROM ls_funcs.
          AUTHORITY-CHECK OBJECT 'V_LIKP_VST'
            ID 'ACTVT' FIELD '03'
            ID 'VSTEL' FIELD ls_funcs-shippingpoint.
          IF sy-subrc <> 0.
            DELETE lt_funcs[].
          ENDIF.
        ENDLOOP.
        DELETE lt_funcs WHERE openqty IS INITIAL.

        zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_funcs ).

        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_funcs ) ).
        ENDIF.

        zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_funcs ).

        zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_funcs ).

        io_response->set_data( lt_funcs ).



      CATCH cx_rap_query_filter_no_range.
    ENDTRY.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.
        CASE io_request->get_entity_id( ).

          WHEN 'ZR_SSD030'.
            get_backorder( io_request = io_request io_response = io_response ).
        ENDCASE.

      CATCH cx_rap_query_provider INTO DATA(lx_query).
      CATCH cx_sy_no_handler INTO DATA(lx_synohandler).
      CATCH cx_sy_open_sql_db.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
