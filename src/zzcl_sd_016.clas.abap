CLASS zzcl_sd_016 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS get_material_description IMPORTING iv_product            TYPE matnr
                                               iv_billingdoc         TYPE zzesd015
                                               iv_billingitem        TYPE zzesd017
                                     RETURNING VALUE(rv_description) TYPE string.
ENDCLASS.



CLASS ZZCL_SD_016 IMPLEMENTATION.


  METHOD get_material_description.
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

        DATA(lv_path) = |/API_PRODUCT_SRV/A_Product('{ iv_product }')/to_ProductBasicText|.
        lv_path = replace( val = lv_path
                           sub = ` `
                           with = `%20`
                           occ = 0 ).
*        lv_path = cl_web_http_utility=>escape_url( lv_path ).
        lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').

        lo_http_client->set_csrf_token(  ).

        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).
        DATA(lv_response) = lo_response->get_text(  ).
        DATA(status) = lo_response->get_status( ).

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

        IF status-code = 200.
          /ui2/cl_json=>deserialize(
          EXPORTING
              json = lv_response
          CHANGING
              data = lt_return
          ).
          READ TABLE lt_return-d-results ASSIGNING FIELD-SYMBOL(<fs_results>) INDEX 1.
          IF sy-subrc = 0.
            rv_description = <fs_results>-longtext.
          ELSE.
            SELECT SINGLE billingdocumentitemtext FROM i_billingdocumentitem
            WITH PRIVILEGED ACCESS
            WHERE billingdocument = @iv_billingdoc
                AND billingdocumentitem = @iv_billingitem
                AND product = @iv_product
            INTO @rv_description.
          ENDIF.
        ELSE.
          SELECT SINGLE billingdocumentitemtext FROM i_billingdocumentitem
          WITH PRIVILEGED ACCESS
          WHERE billingdocument = @iv_billingdoc
              AND billingdocumentitem = @iv_billingitem
              AND product = @iv_product
          INTO @rv_description.
        ENDIF.

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).

    ENDTRY.

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data TYPE STANDARD TABLE OF zc_ssd034 WITH DEFAULT KEY.
    DATA lv_serialnumbers TYPE string.
    lt_original_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
      " Freight Amount
      SELECT SINGLE totalnetamount
      FROM i_billingdocument WITH PRIVILEGED ACCESS
      WHERE billingdocument = @<fs_original_data>-invoicenumber
      INTO @DATA(lv_totalnetamount).

      TRY.
          <fs_original_data>-termsdiscountamount = lv_totalnetamount * <fs_original_data>-termsdiscountpercent / 100.
        CATCH cx_sy_conversion_no_number.
          <fs_original_data>-termsdiscountamount = lv_totalnetamount / 100.
      ENDTRY.

      SELECT SUM( netamount )
      FROM i_billingdocumentitem WITH PRIVILEGED ACCESS AS _billingdocumentitem
      INNER JOIN i_product WITH PRIVILEGED ACCESS AS _product
      ON _billingdocumentitem~product = _product~product
          AND _product~productgroup  = 'Z001'
      WHERE _billingdocumentitem~billingdocument = @<fs_original_data>-invoicenumber
      GROUP BY _billingdocumentitem~billingdocument
      INTO TABLE @DATA(lt_freight_amount).

      IF lines( lt_freight_amount ) > 0.
        <fs_original_data>-freightamount = lt_freight_amount[ 1 ].
      ENDIF.

      " Charge/Allowance 1 Description
      SELECT
          _billingdocumentitem~netamount,
          _billingdocumentitem~product
      FROM i_billingdocumentitem WITH PRIVILEGED ACCESS AS _billingdocumentitem
      INNER JOIN i_product WITH PRIVILEGED ACCESS AS _product
      ON _billingdocumentitem~product = _product~product
          AND _product~productgroup = 'Z003'
      WHERE _billingdocumentitem~billingdocument = @<fs_original_data>-invoicenumber
      INTO TABLE @DATA(lt_description1).

      IF lines( lt_description1 ) > 1.
        <fs_original_data>-chargeallowance1description = 'Discount'.
      ELSEIF lines( lt_description1 ) > 0.
        <fs_original_data>-chargeallowance1description = get_material_description( iv_product = lt_description1[ 1 ]-product
                                                                                   iv_billingdoc = <fs_original_data>-invoicenumber
                                                                                   iv_billingitem = <fs_original_data>-linenumber ).
      ENDIF.

      " Charge/Allowance 1 Amount
      SELECT SUM( netamount )
      FROM i_billingdocumentitem WITH PRIVILEGED ACCESS AS _billingdocumentitem
      INNER JOIN i_product WITH PRIVILEGED ACCESS AS _product
      ON _billingdocumentitem~product = _product~product
          AND _product~productgroup = 'Z003'
      WHERE _billingdocumentitem~billingdocument = @<fs_original_data>-invoicenumber
      GROUP BY _billingdocumentitem~billingdocument
      INTO TABLE @DATA(lt_chargeallowance1_amount).

      IF lines( lt_chargeallowance1_amount ) > 0.
        <fs_original_data>-chargeallowance1amount = lt_chargeallowance1_amount[ 1 ].
      ENDIF.

      " Charge/Allowance 2 Description
      SELECT
          _billingdocumentitem~netamount,
          _billingdocumentitem~product
      FROM i_billingdocumentitem WITH PRIVILEGED ACCESS AS _billingdocumentitem
      INNER JOIN i_product WITH PRIVILEGED ACCESS AS _product
      ON _billingdocumentitem~product = _product~product
          AND _product~productgroup = 'Z004'
      WHERE _billingdocumentitem~billingdocument = @<fs_original_data>-invoicenumber
      INTO TABLE @DATA(lt_description2).

      IF lines( lt_description2 ) > 1.
        <fs_original_data>-chargeallowance2description = 'Charge'.
      ELSEIF lines( lt_description2 ) > 0.
        <fs_original_data>-chargeallowance2description = get_material_description( iv_product = lt_description2[ 1 ]-product
                                                                                   iv_billingdoc = <fs_original_data>-invoicenumber
                                                                                   iv_billingitem = <fs_original_data>-linenumber ).
      ENDIF.

      " Charge/Allowance 2 Amount
      SELECT SUM( netamount )
      FROM i_billingdocumentitem WITH PRIVILEGED ACCESS AS _billingdocumentitem
      INNER JOIN i_product WITH PRIVILEGED ACCESS AS _product
      ON _billingdocumentitem~product = _product~product
          AND _product~productgroup = 'Z004'
      WHERE _billingdocumentitem~billingdocument = @<fs_original_data>-invoicenumber
      GROUP BY _billingdocumentitem~billingdocument
      INTO TABLE @DATA(lt_chargeallowance2_amount).

      IF lines( lt_chargeallowance2_amount ) > 0.
        <fs_original_data>-chargeallowance2amount = lt_chargeallowance2_amount[ 1 ].
      ENDIF.

      <fs_original_data>-productdescription = get_material_description( iv_product = <fs_original_data>-supplierproductnumber
                                                                        iv_billingdoc = <fs_original_data>-invoicenumber
                                                                        iv_billingitem = <fs_original_data>-linenumber ).

      " Product Serial Number
      IF <fs_original_data>-billingtype = 'G2' OR <fs_original_data>-billingtype = 'S2'.
        SELECT subsequentdocument,subsequentdocumentitem
        FROM i_salesdocitmsubsqntprocflow WITH PRIVILEGED ACCESS
        WHERE ( salesdocument,salesdocumentitem ) IN ( SELECT salesdocument,salesdocumentitem
        FROM i_salesdocitmsubsqntprocflow WITH PRIVILEGED ACCESS
        WHERE subsequentdocument = @<fs_original_data>-invoicenumber
          AND subsequentdocumentitem = @<fs_original_data>-linenumber
          AND sddocumentcategory = 'H' )
        AND subsequentdocumentcategory = 'T'
        INTO TABLE @DATA(lt_subsequent).

        IF lines( lt_subsequent ) > 0.
          SELECT DISTINCT serialnumber
          FROM i_serialnumberdeliverydocument WITH PRIVILEGED ACCESS
          WHERE ( deliverydocument,deliverydocumentitem ) IN ( SELECT subsequentdocument,subsequentdocumentitem
          FROM @lt_subsequent AS lts )
          INTO TABLE @DATA(lt_serialnumbers).

          IF lines( lt_serialnumbers ) > 0.
            LOOP AT lt_serialnumbers ASSIGNING FIELD-SYMBOL(<fs_serialnumber>).
              IF sy-tabix = 1.
                lv_serialnumbers = <fs_serialnumber>-serialnumber.
              ELSE.
                CONCATENATE lv_serialnumbers ',' <fs_serialnumber>-serialnumber INTO lv_serialnumbers.
              ENDIF.

            ENDLOOP.

            <fs_original_data>-productserialnumber = lv_serialnumbers.
          ENDIF.
        ELSE.
          SELECT zwarrantymaterial
          FROM zr_tsd001
          WHERE zwarrantytype = 'EXTEND'
            AND zwarrantymaterial = @<fs_original_data>-supplierproductnumber
          INTO TABLE @DATA(lt_zwarranty_1).

          IF lines( lt_zwarranty_1 ) > 0.
            SELECT SINGLE
*            concat( yy1_warrantymaterial_bdi,concat( '-',yy1_warrantyserial_bdi ) ) AS warrantyinfo
             yy1_warrantyserial_bdi AS warrantyinfo
            FROM i_billingdocumentitem WITH PRIVILEGED ACCESS
            WHERE billingdocument = @<fs_original_data>-invoicenumber
              AND billingdocumentitem = @<fs_original_data>-linenumber
            INTO @DATA(lv_warrantyinfo).

            <fs_original_data>-productserialnumber = lv_warrantyinfo.
          ENDIF.
        ENDIF.

      ELSEIF <fs_original_data>-billingtype = 'F2' OR <fs_original_data>-billingtype = 'S1'.
        SELECT zwarrantymaterial
        FROM zr_tsd001 WITH PRIVILEGED ACCESS
        WHERE zwarrantytype = 'EXTEND'
          AND zwarrantymaterial = @<fs_original_data>-supplierproductnumber
        INTO TABLE @DATA(lt_zwarranty).

        IF lines( lt_zwarranty ) > 0.
          SELECT SINGLE
*          concat( yy1_warrantymaterial_bdi,concat( '-',yy1_warrantyserial_bdi ) ) AS warrantyinfo
          yy1_warrantyserial_bdi AS warrantyinfo
          FROM i_billingdocumentitem WITH PRIVILEGED ACCESS
          WHERE billingdocument = @<fs_original_data>-invoicenumber
            AND billingdocumentitem = @<fs_original_data>-linenumber
          INTO @DATA(lv_warrantyserial).

          <fs_original_data>-productserialnumber = lv_warrantyserial.
        ELSE.
          SELECT DISTINCT serialnumber
          FROM i_serialnumberdeliverydocument WITH PRIVILEGED ACCESS
          WHERE ( deliverydocument,deliverydocumentitem ) IN ( SELECT subsequentdocument,subsequentdocumentitem
          FROM i_salesdocitmsubsqntprocflow WITH PRIVILEGED ACCESS
          WHERE ( salesdocument,salesdocumentitem ) IN ( SELECT salesdocument,salesdocumentitem
          FROM i_salesdocitmsubsqntprocflow WITH PRIVILEGED ACCESS
          WHERE subsequentdocument = @<fs_original_data>-invoicenumber
            AND subsequentdocumentitem = @<fs_original_data>-linenumber
            AND sddocumentcategory = 'C' )
          AND subsequentdocumentcategory = 'J' )
          INTO TABLE @lt_serialnumbers.

          IF lines( lt_serialnumbers ) > 0.
            LOOP AT lt_serialnumbers ASSIGNING <fs_serialnumber>.
              IF sy-tabix = 1.
                lv_serialnumbers = <fs_serialnumber>-serialnumber.
              ELSE.
                CONCATENATE lv_serialnumbers ',' <fs_serialnumber>-serialnumber INTO lv_serialnumbers.
              ENDIF.

            ENDLOOP.

            <fs_original_data>-productserialnumber = lv_serialnumbers.
          ENDIF.

        ENDIF.

      ENDIF.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
