CLASS zcl_virt_elem_log_02 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VIRT_ELEM_LOG_02 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    IF iv_entity = 'Z_C_TRAVEL_LOG_02'.
      LOOP AT it_requested_calc_elements INTO DATA(ls_req_cal_elemt).

        IF ls_req_cal_elemt = 'DISCOUNTPRICE'.

          APPEND 'TOTALPRICE' TO et_requested_orig_elements.

        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA lt_ori_data TYPE STANDARD TABLE OF z_c_travel_log_02 WITH DEFAULT KEY.

    lt_ori_data = CORRESPONDING #( it_original_data  ).

    LOOP AT lt_ori_data ASSIGNING FIELD-SYMBOL(<fs_ori_data>).
      <fs_ori_data>-DiscountPrice = <fs_ori_data>-TotalPrice + ( <fs_ori_data>-TotalPrice * ( 1 / 10 ) ).
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_ori_data ).

  ENDMETHOD.
ENDCLASS.
