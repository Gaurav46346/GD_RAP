@EndUserText.label: 'Student Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_GD_STUDENT
  provider contract transactional_query
  as projection on ZI_GD_STUDENT
{
      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
  key Rollno,
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      Name
}
