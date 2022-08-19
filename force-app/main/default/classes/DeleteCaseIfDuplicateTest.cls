@isTest
public class DeleteCaseIfDuplicateTest {
    
    static testmethod void duplicateCase(){
    Case c= new Case(Subject='Login issue',CreatedDate=System.now(),Origin='Email',SuppliedEmail='kumar@astm.com');
        
        Insert c;
        
        Case c2 = new Case(Subject='Login issue',CreatedDate=System.now().addseconds(-2),Origin='Email',SuppliedEmail='kumar@astm.com');
        
        Insert c2;
}
    static testmethod void notaduplicatecase(){
        Case c= new Case(Subject='Maintenance Task',CreatedDate=System.now(),Origin='Email',SuppliedEmail='kumar@astm.com');
        
        Insert c;
        
        Case c2 = new Case(Subject='Login issue',CreatedDate=System.now().addhours(-2),Origin='Email',SuppliedEmail='test@astm.com');
        
        Insert c2;
    }
}