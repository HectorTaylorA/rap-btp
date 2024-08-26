CLASS zcl_ext_update_ent_log_02 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_EXT_UPDATE_ENT_LOG_02 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    MODIFY ENTITIES OF z_i_travel_log_02
        ENTITY Travel
        UPDATE FIELDS ( AgencyId Description )
        WITH VALUE #( ( TravelId = '000000001'
                      AgencyId = '070717'
                      Description = 'New External Update' ) )
             FAILED DATA(failed)
             REPORTED DATA(reported).

    READ ENTITIES OF z_i_travel_log_02
        ENTITY Travel
        FIELDS ( AgencyId Description )
        WITH VALUE #( ( TravelId = '000000001' )  )
        RESULT DATA(lt_travel_Data)
            FAILED failed
            REPORTED reported.


    COMMIT ENTITIES.
    IF failed IS INITIAL.
      out->write( 'Commit Realizaado' ).
    ELSE.
      out->write( 'Commit Erroneo' ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
