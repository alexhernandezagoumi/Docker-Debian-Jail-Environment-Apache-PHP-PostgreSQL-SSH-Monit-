<?php
session_start();

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $usuario = $_POST['usuario'];
    $contrasena = $_POST['contrasena'];

    // Conexion a PostgreSQL (ajusta los valores segun tu entorno)
    $conn = pg_connect("host=localhost dbname=prueba1 user=usuario1 password=password1");

    if (!$conn) {
        die("Error de conexion a la base de datos.");
    }

    // Buscar el usuario
    $result = pg_query_params($conn, "SELECT * FROM credenciales WHERE nombre_usuario = $1", [$usuario]);

    if ($row = pg_fetch_assoc($result)) {
        // Verificar contrasena usando crypt
        $check = pg_query_params($conn,
            "SELECT nombre_usuario FROM credenciales WHERE nombre_usuario = $1 AND contrasena = crypt($2, contrasena)",
            [$usuario, $contrasena]
        );

        if (pg_num_rows($check) > 0) {
            $_SESSION['usuario'] = $usuario;
            header("Location: testBDD.php");
            exit;
        } else {
            $error = "Contraseña incorrecta.";
        }
    } else {
        $error = "Usuario no encontrado.";
    }
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f4f7fa;
            margin: 0;
            padding: 0;
        }
        .login-container {
            width: 300px;
            padding: 20px;
            margin: 100px auto;
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        h2 {
            text-align: center;
            color: #333;
        }
        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
        }
        input[type="submit"] {
            width: 100%;
            padding: 12px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }
        input[type="submit"]:hover {
            background-color: #0056b3;
        }
        .error {
            color: #dc3545;
            text-align: center;
            margin: 10px 0;
            font-weight: bold;
        }
    </style>
</head>
<body>

<div class="login-container">
    <h2>Iniciar sesión</h2>

    <?php if (!empty($error)) echo "<p class='error'>$error</p>"; ?>

    <form method="post">
        <input type="text" name="usuario" placeholder="Usuario" required><br>
        <input type="password" name="contrasena" placeholder="Contraseña" required><br>
        <input type="submit" value="Entrar">
    </form>
</div>

</body>
</html>
