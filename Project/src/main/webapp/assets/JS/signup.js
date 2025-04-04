document.getElementById('signupForm').addEventListener('submit', function(event) {
    event.preventDefault();

    let name = document.getElementById('name').value;
    let email = document.getElementById('email').value;
    let password = document.getElementById('pwd').value;

    if (name && email && password) {
        localStorage.setItem('userEmail', email);
        localStorage.setItem('userPassword', password);
        alert('Sign-up successful! Redirecting to login.');
        window.location.href = 'login.html'; // Redirect to login page
    } else {
        alert('Please fill all fields.');
    }
    document.getElementById("searchBox").addEventListener("keyup", function() {
        let filter = this.value.toLowerCase();
        let items = document.querySelectorAll(".list-group-item");

        items.forEach(item => {
            if (item.textContent.toLowerCase().includes(filter)) {
                item.style.display = "block";
            } else {
                item.style.display = "none";
            }
        });
    });
    function validateForm() {
            let password = document.getElementById("password").value;
            let confirmPassword = document.getElementById("confirmPassword").value;

            if (password !== confirmPassword) {
                alert("Passwords do not match!");
                return false;  // Prevent form submission
            }
            return true;  // Allow form submission
        }

});
