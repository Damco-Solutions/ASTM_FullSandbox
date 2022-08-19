trigger RestrictContactAccess on Contact (before insert) {
    
    //List<Account> CPSSAccounts = [Select Id, Name,ownerId,Owner.name FROM Account WHERE Owner.Name='CPSSDO'];
    
    //for(Contact con: Trigger.New){
        //if (CPSSAccounts.contains(con.AccountId)){
            
        //}
}

//}