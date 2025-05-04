# formacion

Script creado para un proyecto de trabajo, en el cual, tenemos que enviar un archivo desde WSL a un cliente windows.

<h1>Cosas a tener en cuenta:</h1>

- La ruta en Windows debe convertirse a estilo UNIX si estás usando WSL o OpenSSH en Windows (C:/Users/... → /c/Users/...).

- Si no deseas pedir contraseña cada vez, puedes:

- Configurar autenticación con clave SSH.

- O También, puedes introducir la clave 
