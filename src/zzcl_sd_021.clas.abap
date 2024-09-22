CLASS zzcl_sd_021 DEFINITION
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
    TYPES:BEGIN OF ty_tab1,
            language  TYPE string,
            longtext  TYPE string,
            product   TYPE string,
            _metadata TYPE ty_t,
          END OF ty_tab1.

    TYPES:BEGIN OF ty_tab2,
            material        TYPE string,
            plant           TYPE string,
            storagelocation TYPE string,
            MatlWrhsStkQtyInMatlBaseUnit TYPE p LENGTH 8 DECIMALS 3,
          END OF ty_tab2.
    DATA:BEGIN OF ls_data1,
            results TYPE TABLE OF ty_tab1,
         END OF ls_data1.
    DATA:BEGIN OF lt_return1,
            d LIKE ls_data1,
         END OF lt_return1.
    DATA:BEGIN OF ls_data2,
            results TYPE TABLE OF ty_tab2,
         END OF ls_data2.
    DATA:BEGIN OF lt_return2,
            d LIKE ls_data2,
         END OF lt_return2.



    METHODS get_data IMPORTING io_request  TYPE REF TO if_rap_query_request
                               io_response TYPE REF TO if_rap_query_response
                     RAISING   cx_rap_query_prov_not_impl
                               cx_rap_query_provider.

    METHODS get_item_description RETURNING VALUE(rt_description) LIKE lt_return1.

    METHODS get_unrestricted_qty RETURNING VALUE(rt_qty) LIKE lt_return2.
ENDCLASS.



CLASS ZZCL_SD_021 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_data TYPE TABLE OF ZR_SSD049,
          ls_data TYPE ZR_SSD049,

          lt_description      LIKE lt_return1,
          lt_unrestricted_qty LIKE lt_return2,

          lr_itemno TYPE RANGE OF I_Product-Product,
          lr_plant  TYPE RANGE OF werks_d.

    TRY.
        DATA(lo_filter) = io_request->get_filter(  ).
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
    CATCH cx_rap_query_filter_no_range.
    ENDTRY.

    LOOP AT lt_filters ASSIGNING FIELD-SYMBOL(<lfs_filter>).
        TRANSLATE <lfs_filter>-name TO UPPER CASE.
        CASE <lfs_filter>-name.
          WHEN 'ITEMNO'.
            MOVE-CORRESPONDING <lfs_filter>-range TO lr_itemno.
          WHEN 'PLANT'.
            MOVE-CORRESPONDING <lfs_filter>-range TO lr_plant.
         ENDCASE.
    ENDLOOP.

    SELECT
        _ProductPlantBasic~Product,
        _ProductPlantBasic~Plant,
        _PlantStdVH~PlantName,
        _Product~ProductGroup,
        _ProductGroupText_2~ProductGroupText
    FROM I_ProductPlantBasic WITH PRIVILEGED ACCESS AS _ProductPlantBasic
    INNER JOIN I_PlantStdVH WITH PRIVILEGED ACCESS AS _PlantStdVH
        ON _ProductPlantBasic~Plant = _PlantStdVH~Plant
    LEFT JOIN I_Product WITH PRIVILEGED ACCESS AS _Product
        ON _Product~Product = _ProductPlantBasic~Product
    LEFT JOIN I_ProductGroupText_2 WITH PRIVILEGED ACCESS AS _ProductGroupText_2
        ON _ProductGroupText_2~ProductGroup = _Product~ProductGroup
        AND _ProductGroupText_2~Language = 'E'
    WHERE _ProductPlantBasic~Plant <> '1712'
        AND _ProductPlantBasic~Product IN @lr_itemno
        AND _ProductPlantBasic~Plant IN @lr_plant
        AND _Product~ProductType IN ( 'FERT','ZERT','ERSA','ZRSA' )
    INTO TABLE @DATA(lt_product_plant).

    LOOP AT lt_product_plant ASSIGNING FIELD-SYMBOL(<fs_product_plant>).
        AUTHORITY-CHECK OBJECT 'ZZ_AUTH01' ##AUTH_FLD_MISSING
        ID 'ZZWERKS' FIELD <fs_product_plant>-Plant
        ID 'ACTVT' FIELD '03'.
        IF sy-subrc <> 0.
            DELETE lt_product_plant[].
        ENDIF.
    ENDLOOP.

    lt_description = get_item_description( ).
    SORT lt_description-d-results BY Product.

    lt_unrestricted_qty = get_unrestricted_qty(  ).
    SORT lt_unrestricted_qty-d-results BY Material Plant StorageLocation.

    SELECT
        _SalesDocument~SalesDocument,
        _SalesDocument~SalesOrganization,
        CASE WHEN _SalesDocumentTypeLangDepdnt~SalesDocumentTypeLangDepdnt is NULL
        THEN _SalesDocument~SalesDocumentType
        ELSE _SalesDocumentTypeLangDepdnt~SalesDocumentTypeLangDepdnt
        END AS SalesDocumentType
    FROM I_SalesDocument WITH PRIVILEGED ACCESS AS _SalesDocument
    INNER JOIN I_SalesDocumentItem WITH PRIVILEGED ACCESS AS _SalesDocumentItem
    ON _SalesDocument~SalesDocument = _SalesDocumentItem~SalesDocument
    LEFT JOIN I_SalesDocumentTypeLangDepdnt WITH PRIVILEGED ACCESS AS _SalesDocumentTypeLangDepdnt
    ON _SalesDocument~SalesDocumentType = _SalesDocumentTypeLangDepdnt~SalesDocumentType
    AND _SalesDocumentTypeLangDepdnt~Language = @sy-langu
    WHERE _SalesDocumentItem~Product IN @lr_itemno
    AND _SalesDocumentItem~Plant IN @lr_plant
    INTO TABLE @DATA(lt_salestype).

    SELECT DISTINCT
        SalesDocument,
        SalesDocumentItem
    FROM I_SalesDocumentScheduleLine WITH PRIVILEGED ACCESS AS _SalesDocumentScheduleLine
    WHERE ( SalesDocument,SalesDocumentItem ) IN ( SELECT
        ls~SalesDocument,
        _SalesDocumentItem~SalesDocumentItem
    FROM @lt_salestype AS ls
    INNER JOIN I_SalesDocumentItem WITH PRIVILEGED ACCESS AS _SalesDocumentItem
        ON ls~SalesDocument = _SalesDocumentItem~SalesDocument
    WHERE ls~SalesDocumentType NOT IN ( 'CBAR','CBRE','CR','DR','GA2' )
        AND _SalesDocumentItem~SalesDocumentRjcnReason = ''
        AND _SalesDocumentItem~Product IN @lr_itemno
        AND _SalesDocumentItem~Plant IN @lr_plant )
        AND ScheduleLineCategory IN ( 'CP','CN' )
    INTO TABLE @DATA(lt_salesdoc).

    LOOP AT lt_salesdoc ASSIGNING FIELD-SYMBOL(<fs_salesdoc>).
        SELECT DISTINCT
            SubsequentDocument,
            SubsequentDocumentItem
        FROM I_SalesDocItmSubsqntProcFlow WITH PRIVILEGED ACCESS AS _SalesDocItmSubsqntProcFlow
        WHERE SalesDocument = @<fs_salesdoc>-SalesDocument
          AND SalesDocumentItem = @<fs_salesdoc>-SalesDocumentItem
          AND SubsequentDocumentCategory = 'J'
        INTO TABLE @DATA(lt_subsequentdoc).

        IF lt_subsequentdoc IS NOT INITIAL.
            SELECT
                DeliveryDocument,
                DeliveryDocumentItem,
                Plant,
                Product,
                SUM( ActualDeliveryQuantity ) AS value_a
            FROM I_DeliveryDocumentItem WITH PRIVILEGED ACCESS AS _DeliveryDocumentItem
            INNER JOIN @lt_subsequentdoc AS ls
                ON _DeliveryDocumentItem~DeliveryDocument = ls~SubsequentDocument
               AND _DeliveryDocumentItem~DeliveryDocumentItem = ls~SubsequentDocumentItem
            WHERE GoodsMovementStatus <> 'C'
               AND Product IN @lr_itemno
               AND Plant IN @lr_plant
            GROUP BY DeliveryDocument,DeliveryDocumentItem,Plant,Product
            APPENDING TABLE @DATA(lt_value_a).

            SELECT SINGLE
                OrderQuantity
            FROM I_SalesDocumentItem
            WHERE SalesDocument = @<fs_salesdoc>-SalesDocument
              AND SalesDocumentItem = @<fs_salesdoc>-SalesDocumentItem
            INTO @DATA(lv_orderquantity).

            LOOP AT lt_subsequentdoc ASSIGNING FIELD-SYMBOL(<fs_subsequentdoc>).
                SELECT SINGLE
                    ActualDeliveryQuantity
                FROM I_DeliveryDocumentItem WITH PRIVILEGED ACCESS AS _DeliveryDocumentItem
                WHERE DeliveryDocument = @<fs_subsequentdoc>-SubsequentDocument
                  AND DeliveryDocumentItem = @<fs_subsequentdoc>-SubsequentDocumentItem
                INTO @DATA(lv_actualdeliveryqty).

                IF lv_actualdeliveryqty <> lv_orderquantity.
                    SELECT
                        _SalesDocumentItem~SalesDocument,
                        _SalesDocumentItem~SalesDocumentItem,
                        _SalesDocumentScheduleLine~ScheduleLine,
                        _SalesDocumentItem~Plant,
                        _SalesDocumentItem~Product,
                        SUM( _SalesDocumentScheduleLine~OpenConfdDelivQtyInOrdQtyUnit ) AS value_c
                    FROM I_SalesDocumentItem WITH PRIVILEGED ACCESS AS _SalesDocumentItem
                    INNER JOIN I_SalesDocumentScheduleLine WITH PRIVILEGED ACCESS AS _SalesDocumentScheduleLine
                        ON _SalesDocumentItem~SalesDocument = _SalesDocumentScheduleLine~SalesDocument
                       AND _SalesDocumentItem~SalesDocumentItem = _SalesDocumentScheduleLine~SalesDocumentItem
                    WHERE _SalesDocumentItem~SalesDocument = @<fs_salesdoc>-SalesDocument
                       AND _SalesDocumentItem~SalesDocumentItem = @<fs_salesdoc>-SalesDocumentItem
                       AND NOT ( _SalesDocumentScheduleLine~OpenReqdDelivQtyInOrdQtyUnit = 0
                       AND _SalesDocumentScheduleLine~OpenConfdDelivQtyinOrdQtyUnit = 0 )
                       AND _SalesDocumentScheduleLine~ConfdOrderQtyByMatlAvailCheck <> _SalesDocumentScheduleLine~DeliveredQtyInOrderQtyUnit
                       AND _SalesDocumentItem~Product IN @lr_itemno
                       AND _SalesDocumentItem~Plant IN @lr_plant
                    GROUP BY _SalesDocumentItem~SalesDocument,_SalesDocumentItem~SalesDocumentItem,_SalesDocumentScheduleLine~ScheduleLine,Plant,Product
                    APPENDING TABLE @DATA(lt_value_c).
                ENDIF.
            ENDLOOP.

        ELSE.
            SELECT
                _SalesDocumentItem~SalesDocument,
                _SalesDocumentItem~SalesDocumentItem,
                _SalesDocumentScheduleLine~ScheduleLine,
                _SalesDocumentItem~Plant,
                _SalesDocumentItem~Product,
                SUM( _SalesDocumentScheduleLine~ConfdOrderQtyByMatlAvailCheck ) AS value_b
            FROM I_SalesDocumentItem WITH PRIVILEGED ACCESS AS _SalesDocumentItem
            INNER JOIN I_SalesDocumentScheduleLine WITH PRIVILEGED ACCESS AS _SalesDocumentScheduleLine
               ON _SalesDocumentItem~SalesDocument = _SalesDocumentScheduleLine~SalesDocument
              AND _SalesDocumentItem~SalesDocumentItem = _SalesDocumentScheduleLine~SalesDocumentItem
            WHERE _SalesDocumentItem~SalesDocument = @<fs_salesdoc>-SalesDocument
              AND _SalesDocumentItem~SalesDocumentItem = @<fs_salesdoc>-SalesDocumentItem
              AND _SalesDocumentItem~Product IN @lr_itemno
              AND _SalesDocumentItem~Plant IN @lr_plant
            GROUP BY _SalesDocumentItem~SalesDocument,_SalesDocumentItem~SalesDocumentItem,_SalesDocumentScheduleLine~ScheduleLine,Plant,Product
            APPENDING TABLE @DATA(lt_value_b).
        ENDIF.

    ENDLOOP.

    SORT lt_value_b BY SalesDocument SalesDocumentItem ScheduleLine.
    DELETE ADJACENT DUPLICATES FROM lt_value_b COMPARING SalesDocument SalesDocumentItem ScheduleLine.

    SORT lt_value_c BY SalesDocument SalesDocumentItem ScheduleLine.
    DELETE ADJACENT DUPLICATES FROM lt_value_c COMPARING SalesDocument SalesDocumentItem ScheduleLine.

    SORT lt_value_a BY Plant Product.
    SORT lt_value_b BY Plant Product.
    SORT lt_value_c BY Plant Product.

    LOOP AT lt_product_plant ASSIGNING FIELD-SYMBOL(<lfs_product_plant>).
        ls_data-ItemNo = <lfs_product_plant>-Product.
        ls_data-MaterialGroup = <lfs_product_plant>-ProductGroup.
        ls_data-MaterialGroupDescription = <lfs_product_plant>-ProductGroupText.
        CONCATENATE <lfs_product_plant>-Plant '-' <lfs_product_plant>-PlantName INTO ls_data-PlantName SEPARATED BY ` `.
        ls_data-Plant = <lfs_product_plant>-Plant.

        READ TABLE lt_description-d-results ASSIGNING FIELD-SYMBOL(<fs_description>)
        WITH KEY Product = <lfs_product_plant>-Product BINARY SEARCH.
        IF sy-subrc = 0.
            ls_data-ItemDescription = <fs_description>-longtext.
        ELSE.
            SELECT SINGLE ProductDescription
            FROM I_ProductDescription WITH PRIVILEGED ACCESS AS _ProductDescription
            WHERE _ProductDescription~Product = @<lfs_product_plant>-Product
                AND _ProductDescription~Language = 'E'
            INTO @ls_data-ItemDescription.
        ENDIF.

        READ TABLE lt_value_a ASSIGNING FIELD-SYMBOL(<fs_value_a>)
        WITH KEY Plant   = <lfs_product_plant>-Plant
                 Product = <lfs_product_plant>-Product BINARY SEARCH.
        IF sy-subrc = 0.
            LOOP AT lt_value_a INTO DATA(ls_value_a) FROM sy-tabix.
                IF ls_value_a-Plant <> <lfs_product_plant>-Plant
                OR ls_value_a-Product <> <lfs_product_plant>-Product.
                    EXIT.
                ENDIF.
                ls_data-Committed_ += ls_value_a-value_a.
            ENDLOOP.
        ENDIF.

        READ TABLE lt_value_b ASSIGNING FIELD-SYMBOL(<fs_value_b>)
        WITH KEY Plant   = <lfs_product_plant>-Plant
                 Product = <lfs_product_plant>-Product BINARY SEARCH.
        IF sy-subrc = 0.
            LOOP AT lt_value_b INTO DATA(ls_value_b) FROM sy-tabix.
                IF ls_value_b-Plant <> <lfs_product_plant>-Plant
                OR ls_value_b-Product <> <lfs_product_plant>-Product.
                    EXIT.
                ENDIF.
                ls_data-Committed_ += ls_value_b-value_b.
            ENDLOOP.
        ENDIF.

        READ TABLE lt_value_c ASSIGNING FIELD-SYMBOL(<fs_value_c>)
        WITH KEY Plant   = <lfs_product_plant>-Plant
                 Product = <lfs_product_plant>-Product BINARY SEARCH.
        IF sy-subrc = 0.
            LOOP AT lt_value_c INTO DATA(ls_value_c) FROM sy-tabix.
                IF ls_value_c-Plant <> <lfs_product_plant>-Plant
                OR ls_value_c-Product <> <lfs_product_plant>-Product.
                    EXIT.
                ENDIF.
                ls_data-Committed_ += ls_value_c-value_c.
            ENDLOOP.
        ENDIF.

        READ TABLE lt_unrestricted_qty-d-results ASSIGNING FIELD-SYMBOL(<fs_qty>)
        WITH KEY Material = <lfs_product_plant>-Product
            Plant = <lfs_product_plant>-Plant
            StorageLocation = 'AREG' BINARY SEARCH.
        IF sy-subrc = 0.
            ls_data-RegularBinInventory = <fs_qty>-matlwrhsstkqtyinmatlbaseunit.
        ENDIF.

        ls_data-AvailableQuantity = ls_data-RegularBinInventory - ls_data-Committed_.

        APPEND ls_data TO lt_data.
        CLEAR ls_data.

    ENDLOOP.

    SORT lt_data BY ItemNo Plant.

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


  METHOD get_unrestricted_qty.
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

        DATA(lv_path) = |/API_MATERIAL_STOCK_SRV/A_MatlStkInAcctMod|.
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
              data = rt_qty
          ).
        ENDIF.

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).

    ENDTRY.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.
        CASE io_request->get_entity_id( ).

          WHEN 'ZR_SSD049'.
            get_data( io_request = io_request io_response = io_response ).
        ENDCASE.

      CATCH cx_rap_query_provider INTO DATA(lx_query).
      CATCH cx_sy_no_handler INTO DATA(lx_synohandler).
      CATCH cx_sy_open_sql_db.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
