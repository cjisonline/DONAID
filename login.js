var firebaseConfig = {
    apiKey: " AIzaSyCXEBNOHoGPQ9VDIaO8BnGZNi9uGy21Wig ",
    authDomain: "donaid-d3244.firebaseapp.com ",
    projectId: "donaid-d3244",
    storageBucket: "donaid-d3244.appspot.com",
    messagingSenderId: "240146097284",
    appId: "1:240146097284:android:eafc4f1d40814e961cced1",
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();

// Login
function loginAdmin(){
    var email = document.getElementById("email");
    var password  = document.getElementById("password");

    const promise = auth.signInWithEmailAndPassword(email.value,password.value)
    .then(function(){
        console.log("Login Successful");
        window.location.href = 'dashboard.html'; // Redirect after successful login
    });
    promise.catch(e=>alert(e.message));
}

// Logout
function logoutAdmin(){
    auth.signOut()
    .then(function(){
        console.log("Logout Successful");
        window.location = 'index.html'; // Index redirect upon logout
    });
    alert("Logged Out");
}

// Authenticate user information
firebase.auth().onAuthStateChanged((user)=>{
    if(user){
        var email = user.email;
        alert("User: " + email + " signed in successfully!");
    }
    
    else{
        alert("User not found. Please try again!")
    }
  })
