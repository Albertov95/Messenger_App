struct User {
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
    
    var safeEmail: String {
        emailAddress.safeEmail
    }
    
    let firstName: String
    let emailAddress: String
}
