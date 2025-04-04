document.getElementById('loginForm').addEventListener('submit', function(event) {
    event.preventDefault();

    let email = document.getElementById('email').value;
    let password = document.getElementById('pwd').value;

    let storedEmail = localStorage.getItem('userEmail');
    let storedPassword = localStorage.getItem('userPassword');

    if (email === storedEmail && password === storedPassword) {
        alert('Login successful!');
        // Redirect to a home page or dashboard
        window.location.href = 'dashboard.html';
    } else {
        alert('Invalid email or password. Please sign up first.');
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

});
