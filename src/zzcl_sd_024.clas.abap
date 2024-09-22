CLASS zzcl_sd_024 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES tt_data TYPE TABLE OF ZR_SSD049.
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

    TYPES ty_recipients TYPE c LENGTH 50.

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

    DATA sender TYPE c LENGTH 30.
    DATA conf_name TYPE c LENGTH 30.
    DATA attachment_name TYPE c LENGTH 255.
    DATA subject TYPE string.
    DATA template_name TYPE string.
    DATA content TYPE string.
    DATA recipients TYPE TABLE OF string.
    DATA filename TYPE string.
    DATA mimetype TYPE string.

    METHODS get_parameters IMPORTING it_parameters TYPE if_apj_dt_exec_object=>tt_templ_val.
    METHODS get_all_data EXPORTING et_data  TYPE tt_data.
    METHODS get_item_description RETURNING VALUE(rt_description) LIKE lt_return1.
    METHODS get_unrestricted_qty RETURNING VALUE(rt_qty) LIKE lt_return2.

    METHODS write_to_excel IMPORTING it_data TYPE tt_data
                           EXPORTING ev_file_content TYPE zzattachment.
    METHODS send_email IMPORTING iv_attachment TYPE zzattachment.
ENDCLASS.



CLASS ZZCL_SD_024 IMPLEMENTATION.


  METHOD get_all_data.
    DATA: lt_data TYPE TABLE OF ZR_SSD049,
          ls_data TYPE ZR_SSD049,

          lt_description      LIKE lt_return1,
          lt_unrestricted_qty LIKE lt_return2.

    SELECT
        _ProductPlantBasic~Product,
        _ProductPlantBasic~Plant,
        _PlantStdVH~PlantName
    FROM I_ProductPlantBasic WITH PRIVILEGED ACCESS AS _ProductPlantBasic
    INNER JOIN I_PlantStdVH WITH PRIVILEGED ACCESS AS _PlantStdVH
        ON _ProductPlantBasic~Plant = _PlantStdVH~Plant
    WHERE _ProductPlantBasic~Plant <> '1712'
    INTO TABLE @DATA(lt_product_plant).

    lt_description = get_item_description( ).
    SORT lt_description-d-results BY Product.

    lt_unrestricted_qty = get_unrestricted_qty(  ).
    SORT lt_unrestricted_qty-d-results BY Material Plant StorageLocation.

    SELECT DISTINCT
        SalesDocument,
        SalesDocumentItem
    FROM I_SalesDocumentScheduleLine WITH PRIVILEGED ACCESS AS _SalesDocumentScheduleLine
    WHERE ( SalesDocument,SalesDocumentItem ) IN ( SELECT
        _SalesDocumentItem~SalesDocument,
        _SalesDocumentItem~SalesDocumentItem
    FROM I_SalesDocument WITH PRIVILEGED ACCESS AS _SalesDocument
    INNER JOIN I_SalesDocumentItem WITH PRIVILEGED ACCESS AS _SalesDocumentItem
        ON _SalesDocument~SalesDocument = _SalesDocumentItem~SalesDocument
    WHERE _SalesDocument~SalesDocumentType NOT IN ( 'CBAR','CBRE','CR','DR','GA2' )
        AND _SalesDocumentItem~SalesDocumentRjcnReason = '' )
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

    et_data = lt_data.

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


  METHOD get_parameters.
    LOOP AT it_parameters INTO DATA(ls_parameter).
        CASE ls_parameter-selname.
          WHEN 'P_Sender'.
            sender = ls_parameter-low.
          WHEN 'P_Conf'.
            conf_name = ls_parameter-low.
          WHEN 'P_Temp'.
            template_name = ls_parameter-low.
          WHEN 'P_Attach'.
            attachment_name = ls_parameter-low.
        ENDCASE.
    ENDLOOP.

    SELECT SINGLE UUID FROM ZR_ZT_EMAIL_CONF WHERE ConfigName = @conf_name
    INTO @DATA(uuid).

    READ ENTITIES OF ZR_ZT_EMAIL_CONF
    ENTITY Config
    BY \_Content
    FIELDS ( TemplateName Subject Content ) WITH VALUE #( ( %key-uuid = uuid ) )
    RESULT FINAL(email_conf).

    READ TABLE email_conf ASSIGNING FIELD-SYMBOL(<fs_conf>) WITH KEY TemplateName = template_name.
    IF sy-subrc = 0.
        subject = <fs_conf>-Subject.
        content = <fs_conf>-Content.
    ENDIF.

    READ ENTITIES OF ZR_ZT_EMAIL_CONF
    ENTITY Config
    BY \_Recipent
    FIELDS ( Type Recipent ) WITH VALUE #( ( %key-uuid = uuid ) )
    RESULT FINAL(recipient_conf).

    LOOP AT recipient_conf ASSIGNING FIELD-SYMBOL(<fs_recipient>).
        APPEND <fs_recipient>-Recipent TO recipients.
    ENDLOOP.

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


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'P_Sender' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 30 param_text = 'Email of Sender' changeable_ind = abap_true )
      ( selname = 'P_Conf' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 30 param_text = 'Email Config Name' changeable_ind = abap_true )
      ( selname = 'P_Temp' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 30 param_text = 'Email Template Name' changeable_ind = abap_true )
      ( selname = 'P_Attach' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 255 param_text = 'attachment_name Name' changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'P_Attach' kind = if_apj_dt_exec_object=>parameter sign = 'I' option = 'EQ' low = 'Product Inventory and Availability Report' )
    ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    DATA: lt_data TYPE tt_data.

    DATA: lv_file_content TYPE zzattachment.

    get_parameters( it_parameters ).

    get_all_data( IMPORTING et_data = lt_data ).
    write_to_excel( EXPORTING it_data = lt_data
                    IMPORTING ev_file_content = lv_file_content ).
    send_email( EXPORTING iv_attachment = lv_file_content ).
  ENDMETHOD.


  METHOD send_email.
    DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).

    lo_mail->set_sender( CONV #( sender ) ).

    LOOP AT recipients INTO DATA(recipient).
        lo_mail->add_recipient( CONV #( recipient ) ).
    ENDLOOP.

    lo_mail->set_subject( CONV #( subject ) ).

    DATA(lv_content) = content.

    lo_mail->set_main( cl_bcs_mail_textpart=>create_instance(
                iv_content      = lv_content
                iv_content_type = 'text/html' ) ).

    DATA(lo_attachment) = cl_bcs_mail_binarypart=>create_instance(
                                     iv_content      = iv_attachment
                                     iv_content_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                     iv_filename     = |{ attachment_name }.xlsx| ).

    lo_mail->add_attachment( lo_attachment ).
    lo_mail->send( IMPORTING et_status = DATA(lt_status) ).

  ENDMETHOD.


  METHOD write_to_excel.
    DATA(lo_write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).
    DATA(lo_worksheet) = lo_write_access->get_workbook( )->worksheet->at_position( 1 ).
    DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
        )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 2 )
        )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
        )->get_pattern(  ).

    DATA(lo_cursor) = lo_worksheet->cursor(
        io_column = xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
        io_row = xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
     ).

    " Write Table Header
    lo_cursor->get_cell( )->value->write_from( 'Item No' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Item Description' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Plant' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Committed' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Regular Bin Inventory' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Available Quantity' ).

    TYPES:
        BEGIN OF ts_row,
            ItemNo              TYPE matnr,
            ItemDescription     TYPE string,
            PlantName           TYPE string,
            Committed_          TYPE p LENGTH 7 DECIMALS 3,
            RegularBinInventory TYPE p LENGTH 8 DECIMALS 3,
            AvailableQuantity   TYPE p LENGTH 8 DECIMALS 3,
        END OF ts_row,

        tt_row TYPE STANDARD TABLE OF ts_row WITH DEFAULT KEY.

    DATA lt_rows TYPE tt_row.

    lt_rows = CORRESPONDING #( it_data ).

    lo_worksheet->select( lo_selection_pattern
                )->row_stream(
                )->operation->write_from( REF #( lt_rows )
                )->execute( ).

    DATA(lv_file_content) = lo_write_access->get_file_content( ).
    ev_file_content = lv_file_content.

  ENDMETHOD.
ENDCLASS.
