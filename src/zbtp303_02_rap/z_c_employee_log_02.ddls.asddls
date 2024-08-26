@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Comsuption Employee'
@Metadata.allowExtensions: true
define root view entity Z_C_EMPLOYEE_LOG_02
  as projection on Z_I_EMPLOYEE_LOG_02
{
      @ObjectModel.text.element: [ 'EmployName' ]
  key ENumber      as EmployNumber,
      EName        as EmployName,
      EDepartment  as EmployDepartment,
      Status       as Status,
      JobTittle    as JobTittle,
      StartDate    as StartDate,
      EndDate      as EndDate,
      Email        as Email,
      @ObjectModel.text.element: [ 'ManagerName' ]
      MNumber      as ManagerNumber,
      MName        as ManagerName,
      MDepartment  as ManagerDepartmen,
      @Semantics.user.createdBy: true
      CreaDateTime as CreateddOn,
      CreaUserName as CreatedBy,
      @Semantics.user.lastChangedBy: true
      LchgDateTime as ChangedOn,
      LchgUserName as ChangedBy
}
