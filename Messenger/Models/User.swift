struct User {
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
    
    var safeEmail: String {
        emailAddress.safe
    }
    
    let firstName: String
    let emailAddress: String
}
