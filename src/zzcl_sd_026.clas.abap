CLASS zzcl_sd_026 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:BEGIN OF ty_t,
            id   TYPE string,
            type TYPE string,
            uri  TYPE string,
          END OF ty_t.
    TYPES:BEGIN OF ty_tab,
            language  TYPE string,
            longtext  TYPE string,
            product   TYPE string,
            _metadata TYPE ty_t,
          END OF ty_tab.

    DATA:BEGIN OF ls_data,
            results TYPE TABLE OF ty_tab,
         END OF ls_data.

    DATA:BEGIN OF lt_return,
            d LIKE ls_data,
         END OF lt_return.

    METHODS get_data IMPORTING io_request  TYPE REF TO if_rap_query_request
                               io_response TYPE REF TO if_rap_query_response
                     RAISING   cx_rap_query_prov_not_impl
                               cx_rap_query_provider.

    METHODS get_item_description RETURNING VALUE(rt_description) LIKE lt_return.
ENDCLASS.



CLASS ZZCL_SD_026 IMPLEMENTATION.


  METHOD get_data.

    TYPES ty_material_type   TYPE c LENGTH 4.
    TYPES ty_material_group  TYPE c LENGTH 9.
    TYPES ty_genitemcatgroup TYPE c LENGTH 4.

    DATA: lt_data TYPE TABLE OF ZC_SSD054,
          ls_data TYPE ZC_SSD054,

          lt_description     LIKE lt_return,

          lr_itemcode        TYPE RANGE OF I_Product-Product,
          lr_whcode          TYPE RANGE OF werks_d,
          lr_material_type   TYPE RANGE OF ty_material_type,
          lr_material_group  TYPE RANGE OF ty_material_group,
          lr_genitemcatgroup TYPE RANGE OF ty_genitemcatgroup.

    TRY.
        DATA(lo_filter) = io_request->get_filter(  ).
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
    CATCH cx_rap_query_filter_no_range.
    ENDTRY.

    LOOP AT lt_filters ASSIGNING FIELD-SYMBOL(<lfs_filter>).
        TRANSLATE <lfs_filter>-name TO UPPER CASE.
        CASE <lfs_filter>-name.
          WHEN 'ITEMCODE'.
            MOVE-CORRESPONDING <lfs_filter>-range TO lr_itemcode.
          WHEN 'WHCODE'.
            MOVE-CORRESPONDING <lfs_filter>-range TO lr_whcode.
          WHEN 'MATERIALTYPE'.
            MOVE-CORRESPONDING <lfs_filter>-range TO lr_material_type.
          WHEN 'MATERIALGROUP'.
            MOVE-CORRESPONDING <lfs_filter>-range TO lr_material_group.
          WHEN 'GENITEMCATGROUP'.
            MOVE-CORRESPONDING <lfs_filter>-range TO lr_genitemcatgroup.
         ENDCASE.
    ENDLOOP.

    SELECT *
    FROM ZR_SSD054
    WHERE ItemCode IN @lr_itemcode
      AND WHCode IN @lr_whcode
      AND MaterialType IN @lr_material_type
      AND MaterialGroup IN @lr_material_group
      AND GenItemCatGroup IN @lr_genitemcatgroup
    INTO TABLE @DATA(lt_ssd054).

    lt_description = get_item_description( ).
    SORT lt_description-d-results BY Product.

    SELECT
      _BillingDocumentItem~Plant,
      _BillingDocumentItem~Product,
      _BillingDocumentItem~BillingDocument,
      _BillingDocumentItem~BillingQuantity,
      _BillingDocumentItem~NetAmount,
      _BillingDocumentItem~CostAmount
    FROM I_BillingDocument WITH PRIVILEGED ACCESS AS _BillingDocument
    INNER JOIN I_BillingDocumentItem WITH PRIVILEGED ACCESS AS _BillingDocumentItem
            ON _BillingDocument~BillingDocument = _BillingDocumentItem~BillingDocument
    WHERE _BillingDocument~BillingDocumentIsCancelled = ''
      AND _BillingDocument~CancelledBillingDocument = ''
      AND _BillingDocumentItem~SalesDocumentItemCategory <> 'CBLI'
      AND _BillingDocumentItem~Product IN @lr_itemcode
      AND _BillingDocumentItem~Plant IN @lr_whcode
    INTO TABLE @DATA(lt_no_bom).

    SELECT
      _BillingDocumentItem~Plant,
      _BillingDocumentItem~Product,
      _BillingDocumentItem~BillingDocument,
      _BillingDocumentItem~BillingQuantity,
      _BillingDocumentItem~NetAmount,
      _BillingDocumentItem~CostAmount
    FROM I_BillingDocument WITH PRIVILEGED ACCESS AS _BillingDocument
    INNER JOIN I_BillingDocumentItem WITH PRIVILEGED ACCESS AS _BillingDocumentItem
            ON _BillingDocument~BillingDocument = _BillingDocumentItem~BillingDocument
    WHERE _BillingDocument~BillingDocumentIsCancelled = ''
      AND _BillingDocument~CancelledBillingDocument = ''
      AND _BillingDocumentItem~SalesDocumentItemCategory = 'CBLI'
      AND _BillingDocumentItem~Product IN @lr_itemcode
      AND _BillingDocumentItem~Plant IN @lr_whcode
    INTO TABLE @DATA(lt_bom).

    SORT lt_no_bom BY Plant Product.
    SORT lt_bom BY Plant Product.

    LOOP AT lt_ssd054 ASSIGNING FIELD-SYMBOL(<fs_ssd054>).
        MOVE-CORRESPONDING <fs_ssd054> TO ls_data.

        READ TABLE lt_description-d-results ASSIGNING FIELD-SYMBOL(<fs_description>)
        WITH KEY Product = <fs_ssd054>-ItemCode BINARY SEARCH.
        IF sy-subrc = 0.
            ls_data-ItemDescription = <fs_description>-longtext.
        ELSE.
            SELECT SINGLE ProductName
            FROM I_ProductText WITH PRIVILEGED ACCESS AS _ProductText
            WHERE _ProductText~Product = @<fs_ssd054>-ItemCode
                AND _ProductText~Language = 'E'
            INTO @ls_data-ItemDescription.
        ENDIF.

        READ TABLE lt_no_bom ASSIGNING FIELD-SYMBOL(<fs_no_bom>)
        WITH KEY Plant = <fs_ssd054>-WHCode Product = <fs_ssd054>-ItemCode BINARY SEARCH.
        IF sy-subrc = 0.
            LOOP AT lt_no_bom ASSIGNING <fs_no_bom> FROM sy-tabix.
                IF <fs_no_bom>-Plant <> <fs_ssd054>-WHCode
                OR <fs_no_bom>-Product <> <fs_ssd054>-ItemCode.
                    EXIT.
                ENDIF.
                ls_data-Qty += <fs_no_bom>-BillingQuantity.
                ls_data-SalesAmountItem += <fs_no_bom>-NetAmount.
                ls_data-StockValue += <fs_no_bom>-CostAmount.
            ENDLOOP.

            APPEND ls_data TO lt_data.
            CLEAR: ls_data-StockValue,ls_data-Qty,ls_data-SalesAmountItem.
        ENDIF.

        READ TABLE lt_bom ASSIGNING FIELD-SYMBOL(<fs_bom>)
        WITH KEY Plant = <fs_ssd054>-WHCode Product = <fs_ssd054>-ItemCode BINARY SEARCH.
        IF sy-subrc = 0.
            LOOP AT lt_bom ASSIGNING <fs_bom> FROM sy-tabix.
                IF <fs_bom>-Plant <> <fs_ssd054>-WHCode
                OR <fs_bom>-Product <> <fs_ssd054>-ItemCode.
                    EXIT.
                ENDIF.
                ls_data-Qty += <fs_bom>-BillingQuantity.
                ls_data-SalesAmountItem += <fs_bom>-NetAmount.
                ls_data-StockValue += <fs_bom>-CostAmount.
            ENDLOOP.

            APPEND ls_data TO lt_data.
        ENDIF.

        CLEAR ls_data.

    ENDLOOP.

    SORT lt_data BY ItemCode WHCode.

    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_data ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.

    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_data ).

    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_data ).

    io_response->set_data( lt_data ).

  ENDMETHOD.


  METHOD get_item_description.
    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
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
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

        DATA(lo_request) = lo_http_client->get_http_request(   ).

        lo_http_client->enable_path_prefix( ).

        DATA(lv_path) = |/API_PRODUCT_SRV/A_ProductBasicText|.
        lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').

        lo_http_client->set_csrf_token(  ).

        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).
        DATA(lv_response) = lo_response->get_text(  ).
        DATA(status) = lo_response->get_status( ).

        IF status-code = 200.
          /ui2/cl_json=>deserialize(
          EXPORTING
              json = lv_response
          CHANGING
              data = rt_description
          ).
        ENDIF.

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).

    ENDTRY.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.
        CASE io_request->get_entity_id( ).

          WHEN 'ZC_SSD054'.
            get_data( io_request = io_request io_response = io_response ).
        ENDCASE.

      CATCH cx_rap_query_provider INTO DATA(lx_query).
      CATCH cx_sy_no_handler INTO DATA(lx_synohandler).
      CATCH cx_sy_open_sql_db.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
