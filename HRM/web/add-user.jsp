<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add User</title>

    <style>
        body{
            font-family: Arial;
            margin: 30px;
        }

        form{
            width: 400px;
        }

        input, select{
            width: 100%;
            padding: 10px;
            margin-top: 10px;
            margin-bottom: 20px;
        }

        button{
            padding: 10px 20px;
            background-color: green;
            color: white;
            border: none;
            border-radius: 5px;
        }
    </style>

</head>
<body>

    <h1>Add New User</h1>

    <form action="add-user" method="post">

        Full Name:
        <input type="text" name="fullName" required>

        Email:
        <input type="email" name="email" required>

        Password:
        <input type="password" name="password" required>
        
        Department:
        <select name="department" required>

        <option value="">
            -- Select Department --
        </option>

        <option value="Human Resources">
            Human Resources
        </option>

        <option value="Information Technology">
            Information Technology
        </option>

        <option value="Marketing">
            Marketing
        </option>

        </select>


        Role:
        <select name="role">
        <option value="">
            -- Select Role --
        </option>

          

            <option value="Manager">
                Manager
            </option>

            <option value="Employee">
                Employee
            </option>

        </select>

        <button type="submit">
            Add User
        </button>

    </form>

    <br>

    <a href="user-list">
        Back to User List
    </a>

</body>
</html>
