public with sharing class UserTestDataFactory {

    //massa para usuário a partir do perfil
    public static User userByProfileId(Id profileId){

        String uniqueUserName = 'testuser' + DateTime.now().getTime() + '@testorg.com';

        User user = new User();
        user.Alias = 'testuser';
        user.Email = 'testuser@testorg.com';
        user.EmailEncodingKey ='UTF-8';
        user.LastName ='Test';
        user.LanguageLocaleKey ='en_US';
        user.LocaleSidKey ='en_US';
        user.ProfileId = profileId;
        user.TimeZoneSidKey ='America/Los_Angeles';
        user.UserName = uniqueUserName;

        return user;
    }
}