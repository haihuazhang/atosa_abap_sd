CLASS zzcl_sd_018 DEFINITION
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



CLASS ZZCL_SD_018 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_data TYPE TABLE OF ZC_SSD048,
          lt_description LIKE lt_return,

          lr_customercode   TYPE RANGE OF I_SalesDocument-SoldToParty,
          lr_sonumber       TYPE RANGE OF I_SalesDocument-SalesDocument,
          lr_orderentrydate TYPE RANGE OF I_SalesDocument-CreationDate,
          lr_shiptostore    TYPE RANGE OF I_SalesDocument-YY1_BusinessName_SDH,
          lr_itemstatus     TYPE RANGE OF c.

    DATA: lv_sum_billingqty TYPE I_BillingDocumentItem-BillingQuantity.

    TRY.
        DATA(lo_filter) = io_request->get_filter(  ).
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
    CATCH cx_rap_query_filter_no_range.
    ENDTRY.

    LOOP AT lt_filters ASSIGNING FIELD-SYMBOL(<lfs_filter>).
        TRANSLATE <lfs_filter>-name TO UPPER CASE.
        CASE <lfs_filter>-name.
          WHEN 'CUSTOMERCODE'.
            MOVE-CORRESPONDING <lfs_filter>-range TO lr_customercode.
          WHEN 'SALESORDERNUMBER'.
            MOVE-CORRESPONDING <lfs_filter>-range TO lr_sonumber.
          WHEN 'ORDERENTRYDATE'.
            MOVE-CORRESPONDING <lfs_filter>-range TO lr_orderentrydate.
          WHEN 'SHIPTOSTORENUMBER'.
            MOVE-CORRESPONDING <lfs_filter>-range TO lr_shiptostore.
          WHEN 'ITEMSTATUS'.
            MOVE-CORRESPONDING <lfs_filter>-range TO lr_itemstatus.
         ENDCASE.

    ENDLOOP.

    SELECT *
    FROM ZR_SSD048
    WHERE CustomerCode IN @lr_customercode
    AND   SalesOrderNumber IN @lr_sonumber
    AND   OrderEntryDate IN @lr_orderentrydate
    AND   ShipToStoreNumber IN @lr_shiptostore
    INTO CORRESPONDING FIELDS OF TABLE @lt_data.

    SELECT
        _SalesDocItmSubsqntProcFlow~SalesDocument,
        _SalesDocItmSubsqntProcFlow~SalesDocumentItem,
        _BillingDocumentItem~BillingQuantity
    FROM I_SalesDocItmSubsqntProcFlow WITH PRIVILEGED ACCESS AS _SalesDocItmSubsqntProcFlow
    INNER JOIN I_BillingDocumentItem WITH PRIVILEGED ACCESS AS _BillingDocumentItem
    ON _BillingDocumentItem~BillingDocument = _SalesDocItmSubsqntProcFlow~SubsequentDocument
        AND _BillingDocumentItem~BillingDocumentItem = _SalesDocItmSubsqntProcFlow~SubsequentDocumentItem
    INNER JOIN I_BillingDocument WITH PRIVILEGED ACCESS AS _BillingDocument
    ON _BillingDocument~BillingDocument = _BillingDocumentItem~BillingDocument
    WHERE _SalesDocItmSubsqntProcFlow~SubsequentDocumentCategory = 'M'
        AND _BillingDocument~BillingDocumentIsCancelled = ''
    INTO TABLE @DATA(lt_billing).

    SORT lt_billing BY SalesDocument SalesDocumentItem.

    lt_description = get_item_description(  ).
    SORT lt_description-d-results BY Product.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).

        " ItemStatus
        READ TABLE lt_billing ASSIGNING FIELD-SYMBOL(<fs_billing>) WITH KEY SalesDocument = <lfs_data>-SalesOrderNumber
            SalesDocumentItem = <lfs_data>-SalesDocumentItem BINARY SEARCH.
        IF sy-subrc <> 0.
            <lfs_data>-ItemStatus = 'O'.
            <lfs_data>-RemainingQuantity = <lfs_data>-OrderedQauntity.
        ELSE.
            LOOP AT lt_billing ASSIGNING <fs_billing> FROM sy-tabix.
                IF <fs_billing>-SalesDocument <> <lfs_data>-SalesOrderNumber
                OR <fs_billing>-SalesDocumentItem <> <lfs_data>-SalesDocumentItem.
                    EXIT.
                ENDIF.

                lv_sum_billingqty += <fs_billing>-BillingQuantity.
            ENDLOOP.

            " RemainingQuantity
            <lfs_data>-RemainingQuantity = <lfs_data>-OrderedQauntity - lv_sum_billingqty.

            IF <lfs_data>-RemainingQuantity > 0.
                <lfs_data>-ItemStatus = 'O'.
            ELSE.
                <lfs_data>-ItemStatus = 'C'.
            ENDIF.

            CLEAR lv_sum_billingqty.
        ENDIF.

        " ItemDescription
        READ TABLE lt_description-d-results ASSIGNING FIELD-SYMBOL(<fs_description>)
        WITH KEY product = <lfs_data>-Product BINARY SEARCH.
        IF sy-subrc = 0.
            <lfs_data>-ItemDescription = <fs_description>-longtext.
        ELSE.
            SELECT SINGLE ProductName
            FROM I_ProductText WITH PRIVILEGED ACCESS AS _ProductText
            WHERE _ProductText~Product = @<lfs_data>-Product
                AND _ProductText~Language = 'E'
            INTO @<lfs_data>-ItemDescription.
        ENDIF.

        " UnitPrice
        TRY.
            <lfs_data>-UnitPrice = <lfs_data>-ItemTotal / <lfs_data>-OrderedQauntity.
        CATCH CX_SY_ZERODIVIDE.
            <lfs_data>-UnitPrice = 0.
        ENDTRY.

    ENDLOOP.

    " SalesOrderStatus
    DATA lv_sum_remaining_qty TYPE p LENGTH 8 DECIMALS 2.

    LOOP AT lt_data INTO DATA(ls_data)
    GROUP BY ( SalesOrderNumber = ls_data-SalesOrderNumber )
    ASSIGNING FIELD-SYMBOL(<lfs_group>).

        CLEAR lv_sum_remaining_qty.
        LOOP AT GROUP <lfs_group> ASSIGNING FIELD-SYMBOL(<lfs_member>).
            lv_sum_remaining_qty += <lfs_member>-RemainingQuantity.
        ENDLOOP.

        IF lv_sum_remaining_qty = 0.
            LOOP AT GROUP <lfs_group> ASSIGNING <lfs_member>.
                <lfs_member>-SalesOrderStatus = 'C'.
            ENDLOOP.
        ELSE.
            LOOP AT GROUP <lfs_group> ASSIGNING <lfs_member>.
                <lfs_member>-SalesOrderStatus = 'O'.
            ENDLOOP.
        ENDIF.
    ENDLOOP.

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

          WHEN 'ZC_SSD048'.
            get_data( io_request = io_request io_response = io_response ).
        ENDCASE.

      CATCH cx_rap_query_provider INTO DATA(lx_query).
      CATCH cx_sy_no_handler INTO DATA(lx_synohandler).
      CATCH cx_sy_open_sql_db.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
