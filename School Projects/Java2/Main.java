public class Main {

    public static void main(String[] args) {
        
        User user1 = new User("Michelle", "12345");
        System.out.println("1. " + user1.isValidPassword()); // false -- less than 8 characters

        User user2 = new User("Michelle", "12345Michelle");
        System.out.println("2. " + user2.isValidPassword()); // false -- contains username

        User user3 = new User("Michelle", "12345678");
        System.out.println("3. " + user3.isValidPassword()); // true

        System.out.println("4. " + user2.authenticate("ABCDE")); // false -- incorrect password
        System.out.println("5. " + user2.authenticate("12345Michelle")); // true 

        System.out.println("6. " + user3.authenticate("12345678")); // true
        
        // My tests code below //

        SecureUser badUser = new SecureUser("Michelle", "thisisright");
        System.out.println("badTest1. " + badUser.authenticate("clearlywrong")); // should be false 
        System.out.println("Fails: " + badUser.getFails()); // should be 1 for this user. using getter for fails below allows me to check the counter here
        System.out.println("badTest2. " + badUser.authenticate("clearlywrong2")); // should be false 
        System.out.println("Fails: " + badUser.getFails()); // should be 2 now for this user.
        System.out.println("badTest3. " + badUser.authenticate("clearlywrongthree")); // should be false 
        System.out.println("Fails: " + badUser.getFails()); // should be 3 now for this user. 
        System.out.println("badTest4. " + badUser.authenticate("clearlywrongfour")); // should be false since fail counter for this user has hit 3.
        System.out.println("Fails: " + badUser.getFails()); // should be 4

        /* SecureUser goodUser = new SecureUser("Jimmy", "iamJimmmy");
        System.out.println("badTest5. " + goodUser.authenticate("thisiswrong")); // should be false 
        System.out.println("Fails: " + goodUser.getFails()); // should be 1 for this user
        System.out.println("badTest6. " + goodUser.authenticate("thisiswrongagain")); // should be false 
        System.out.println("Fails: " + goodUser.getFails()); // should be 2 now for this user
        System.out.println("goodTest1. " + goodUser.authenticate("iamJimmy")); // should be false 
        System.out.println("Fails: " + goodUser.getFails()); // should be 0 now this user */ 


    }
}

// My code below //

/**
* Class SecureUser is an extension of the User class and holds a users name and password, along with their failed password
* attempt amounts and if they are locked out or not
* A SecureUser instance 
*
* @author Jailen Duncan
*/
class SecureUser extends User{ // using extends keyword to create a derived/subclass (ref: zybooks 2.1)

    private int fails; // creating new field to track consecutive failed attemps (in instructions)
    private boolean lockout; // creating field for lockout checking

    public SecureUser(String username, String password) { // constructor for my new SecureUser class (ref: zybooks 1.5)
        super(username, password); // getting user and password from the superclass of User in other file. 
        this.fails = 0; // initializing fails with 0 (ref: zybooks 1.11)
        this.lockout = false; // initialising lockout with false (ref: zybooks 1.11)
}
public int getFails() { // getter for fail attemps since private and using outside of class. (ref: zybooks 1.4)
    return fails;
}

@Override     
public boolean authenticate(String inputPassword) {  // overriding the authenticate logic to implement lockout (ref: zybooks 2.3)

if (!super.authenticate(inputPassword)) { // if original authenticate(super) from other file is NOT true, increment the fails and return false as that means wrong password is given.
fails++;

} else if (super.authenticate(inputPassword)) { // if original authenticate (super) IS true, then reset the fails to 0 and return true for authentication.
fails = 0; 
return true;
} 

if (fails == 3) { // if fails gets to 3, lockout status becomes true and the the lockout message prings. Also return false for authentication since a wrong attempt must trigger lockout
lockout = true;
System.out.println("This user will now be locked out due to 3 failed attempts.");
return false;
}

if (lockout == true) { // if lockout is already true this means 3 attemps have been tried and failed. print the lockout message and no authentication.
System.out.println("User has been locked. 3 failed attempts.");
}
return false;
}
}
