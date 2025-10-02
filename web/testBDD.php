<?php
$host = 'localhost';
$port = '5432';
$dbname = 'bddprueba1';
$user = 'usuarioBDD';
$password = '*1234Root';

$conn = pg_connect("host=$host port=$port dbname=$dbname user=$user password=$password");
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Conexión PostgreSQL</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f0f4f8;
            color: #333;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding-top: 50px;
        }

        .container {
            background-color: #fff;
            border: 1px solid #ccc;
            border-radius: 12px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            padding: 30px 40px;
            width: 500px;
            max-width: 90%;
            text-align: center;
        }

        h1 {
            color: #0077cc;
        }

        .success {
            color: green;
            font-weight: bold;
        }

        .error {
            color: red;
            font-weight: bold;
        }

        .info {
            margin-top: 15px;
        }

        code {
            background-color: #eee;
            padding: 4px 8px;
            border-radius: 4px;
            font-family: monospace;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Estado de la conexión</h1>
        <?php if (!$conn): ?>
            <p class="error">❌ Error en la conexión a la base de datos.</p>
        <?php else: ?>
            <p class="success">✅ ¡Conexión exitosa a PostgreSQL!</p>
            <div class="info">
                <p><strong>Usuario conectado:</strong> <code><?php echo $user; ?></code></p>
                <?php
                    $result = pg_query($conn, "SELECT version();");
                    $row = pg_fetch_row($result);
                ?>
                <p><strong>Versión de PostgreSQL:</strong> <code><?php echo $row[0]; ?></code></p>
            </div>
        <?php endif; ?>
    </div>
</body>
</html>

<?php
pg_close($conn);
?>
